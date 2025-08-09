from datetime import datetime
import requests
import psycopg
import socket
import redis
import time
import sys
import os

from pprint import pprint

POSTGRES_DSN = os.getenv("POSTGRES_DSN", "postgresql://postgres:postgres@localhost:5432/postgres")

GITHUB_RATE_LIMIT_ENDPOINT = "https://api.github.com/rate_limit"
GITHUB_API_ENDPOINT = "https://api.github.com/graphql"
GITHUB_API_TOKEN=os.environ.get("GITHUB_API_TOKEN")
HEADERS = {
    "Authorization": f"Bearer {GITHUB_API_TOKEN}"
}
PAGINATION_LOOP_TIME_SLEEP = 1.8
QUEUE_NAME = "github_logins_queue"
INITIAL_PROFILE_LOGIN = "jakubgania"

config = {
    "mainLoop": {
        "limitNumberOfLoops": True,
        "limitCounter": 3
    },
    "followersPaginationLoops": {
        "limitNumberOfLoops": False,
        "limitCounter": 1
    },
    "followingsPaginationLoops": {
        "limitNumberOfLoops": False,
        "limitCounter": 1
    }
}

redis_client = redis.Redis(host='localhost', port=6379, db=0, decode_responses=True)

def enqueue_logins(logins: list[str]):
    """Dodaje wiele loginów do kolejki Redis w jednej operacji."""
    if not logins:
        return
    redis_client.rpush(QUEUE_NAME, *logins)  # * rozpakowuje listę jako argumenty
    print(f"➡️ Added {len(logins)} logins to Redis queue.")

def validate_github_token():
    if not GITHUB_API_TOKEN:
        print("❌ Error: GITHUB_API_TOKEN variable not set.")
        print("Set it e.g. `export GITHUB_API_TOKEN=your_token` and try again.")
        sys.exit(1)

    try:
        response = requests.get(GITHUB_RATE_LIMIT_ENDPOINT, headers=HEADERS, timeout=5)
    except requests.RequestException as error:
        print(f"❌ Failed to connect to GitHub API: {error}")
        sys.exit(1)

    if response.status_code == 401:
        print("❌ Invalid or expired GitHub token.")
        print("Check if the TOKEN is up to date and has the appropriate scopes.")
        sys.exit(1)
    elif response.status_code >= 400:
        print(f"❌ GitHub API returned an error {response.status_code}:")
        print(response.json().get("message", response.text))
        sys.exit(1)

    data = response.json()
    rem = data["resources"]["graphql"]["remaining"]
    reset = data["resources"]["graphql"]["reset"]
    print(f"✅ Token OK - left {rem} queries, reset about {reset} (unix time).")

def get_rate_limit():
    response = requests.get(GITHUB_RATE_LIMIT_ENDPOINT, headers=HEADERS)
    data = response.json()
    remaining = data["resources"]["graphql"]["remaining"]
    reset_time = data["resources"]["graphql"]["reset"]
    return remaining, reset_time

def wait_for_reset(reset_time):
    # only for cutodown test
    # 3480 - this is the equivalent of 58 minutes
    # 3600 - 3480 = 2 minutes to count down
    # reset_time = reset_time - 3480
    while True:
        current_time = time.time()
        seconds_left = int(reset_time - current_time)

        if seconds_left <= 0:
            print("✅ Limit reset, continuing...")
            break

        # end time formatting
        reset_time_str = datetime.fromtimestamp(reset_time).strftime('%Y-%m-%d %H:%M:%S')

        # countdown
        print(f"⏳ To reset: {seconds_left} sec. (o {reset_time_str})", end='\r')

        time.sleep(1)

def check_rate_limit():
    remaining, reset_time = get_rate_limit()
    reset_datetime = datetime.fromtimestamp(reset_time).strftime('%Y-%m-%d %H:%M:%S')
    
    # only for cutodown test
    # remaining = 0

    if remaining == 0:
        wait_for_reset(reset_time)
    else:
        print(" ")
        print(f"api rate limit: {remaining}")
        print(f"api reset time (unix): {reset_time}")
        print(f"api reset time (local): {reset_datetime}")

def wait_for_service(name: str, host: str, port: int, max_attempts: int = 2):
    attempts = 0
    while attempts < max_attempts:
        try:
            with socket.create_connection((host, port), timeout=2):
                print(f"✅ Service: {name} - {host}:{port} is up.")
                return True
        except (socket.timeout, ConnectionRefusedError):
            attempts += 1
            print(f"⏳ Attempt {attempts}: Waiting for service: {name} - {host}:{port}...")
            time.sleep(2)
    
    print(f"❌ Service: {name} - {host}:{port} is not available after {max_attempts} attempts.")
    return False

def check_services_running():
    services = [
        ("postgres", "localhost", 5432),
        ("redis", "localhost", 6379),
        ("typesense", "localhost", 8108),
    ]

    for name, host, port in services:
        wait_for_service(name, host, port)

def format_duration(seconds):
    if seconds < 60:
        return f"{seconds:.2f} seconds"
    elif seconds < 3600:
        minutes = seconds / 60
        return f"{minutes:.2f} minutes"
    else:
        hours = seconds / 3600
        return f"{hours:.2f} hours"
    
QUERY = """
query($username: String!) {
    user(login: $username) {
        login
        name
        organizations(first: 100) {
            nodes {
                name
                login
            }
        }
        followers(first: 100) {
            pageInfo {
                hasNextPage
                endCursor
            }
            nodes {
                name
                login
                followers {
                    totalCount
                }
                following {
                    totalCount
                }
            }
            totalCount
        }
        following(first: 100) {
            pageInfo {
                hasNextPage
                endCursor
            }
            nodes {
                name
                login
                followers {
                    totalCount
                }
                following {
                    totalCount
                }
            }
            totalCount
        }
    }
}
"""

PAGINATION_QUERY_FOLLOWERS = """
query($username: String!, $cursor: String!) {
    user(login: $username) {
        followers(first: 100, after: $cursor) {
            pageInfo {
                hasNextPage
                endCursor
            }
            nodes {
                name
                login
                followers {
                    totalCount
                }
                following {
                    totalCount
                }
            }
            totalCount
        }
    }
}
"""

PAGINATION_QUERY_FOLLOWING = """
query($username: String!, $cursor: String!) {
    user(login: $username) {
        following(first: 100, after: $cursor) {
            pageInfo {
                hasNextPage
                endCursor
            }
            nodes {
                name
                login
                followers {
                    totalCount
                }
                following {
                    totalCount
                }
            }
            totalCount
        }
    }
}
"""

def fetch_api_data(query, variables, headers):
    try:
        response = requests.post(
            GITHUB_API_ENDPOINT,
            json={
                'query': query,
                'variables': variables
            },
            headers=headers
        )

        response.raise_for_status()

        data = response.json()
        if 'errors' in data:
            print(" ")
            print("GraphQL query error")
            print(data["errors"][0]["message"])
            print(" ")

            return []
        
        return response
    except requests.exceptions.HTTPError as http_error:
        print(f"HTTP error occurred: {http_error}")
        return []
    
def get_pending_user_login():
    """get pending user"""
    with psycopg.connect(POSTGRES_DSN) as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT login
                FROM users
                WHERE status = 'pending'
                ORDER BY created_at ASC
                LIMIT 1;
            """)
            row = cur.fetchone()
            return row[0] if row else None
        
def mark_user_done(login: str):
    with psycopg.connect(POSTGRES_DSN) as conn:
        with conn.cursor() as cur:
            cur.execute("UPDATE users SET status = 'done' WHERE login = %s;", (login,))
            conn.commit()

def save_progress(login, mode, cursor):
    """Zapisuje postęp w tabeli scraper_progress (nadpisuje rekord o id=1)."""
    with psycopg.connect(POSTGRES_DSN) as conn:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO scraper_progress (id, current_login, current_mode, current_cursor, last_update)
                VALUES (1, %s, %s, %s, now())
                ON CONFLICT (id) DO UPDATE
                SET current_login = EXCLUDED.current_login,
                    current_mode = EXCLUDED.current_mode,
                    current_cursor = EXCLUDED.current_cursor,
                    last_update = now();
            """, (login, mode, cursor))
            conn.commit()

def load_progress():
    """Ładuje ostatni zapisany postęp (jeśli istnieje)."""
    with psycopg.connect(POSTGRES_DSN) as conn:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT current_login, current_mode, current_cursor
                FROM scraper_progress
                WHERE id = 1;
            """)
            row = cur.fetchone()
            if row and row[0]:
                return row  # (login, mode, cursor)
            return None

def worker():
    start_time = time.time()

    print("✅ start worker")
    print("token: ", GITHUB_API_TOKEN)

    # check_rate_limit()
    print("🚀 so let's move on!")

    check_services_running()

    # get login to init script
    # 1 check redis 
    # 2 check file

    main_loop_counter = 0

    while True:
        if config["mainLoop"]["limitNumberOfLoops"] and config["mainLoop"]["limitCounter"] <= main_loop_counter:
            break

        check_rate_limit()

        # 1. Get the pending user from the database
        username = get_pending_user_login()

        # 2. If there are no users pending in the database → use INITIAL_PROFILE_LOGIN (first time)
        if not username and main_loop_counter == 0:
            username = INITIAL_PROFILE_LOGIN
            print(f"⚠️ No pending users in the database - I use INITIAL_PROFILE_LOGIN: {username}")
        elif not username:
            print("⏳ No users pending - waiting for data...")
            time.sleep(5)
            continue

        print(" ")
        print(f"➡️ Processing user: {username}")
        print(" ")

        variables = {
            "username": username
        }

        response = fetch_api_data(QUERY, variables, HEADERS)
        data = []

        if response:
            data = response.json()

        pprint(data)

        if data and data["data"]["user"] is not None:
            print("data exists")

            organizations = data["data"]["user"]["organizations"]
            if organizations and organizations["nodes"]:
                if organizations["nodes"]:
                    for item in organizations["nodes"]:
                        print("organization", item["login"])
                    else:
                        print("organizations node - empty")

            followers = data["data"]["user"]["followers"]
            if followers:
                hasNextPage = False
                endCursor = ""

                if followers["nodes"]:
                    for node in followers["nodes"]:
                        node_login = node["login"]
                        node_followers_total_count = node["followers"]["totalCount"]
                        node_following_total_count = node["following"]["totalCount"]

                        print(
                            "followers",
                            " - ",
                            node_login,
                            " - ",
                            node_followers_total_count,
                            " - ",
                            node_following_total_count
                        )
                else:
                    print("followers nodes - empty")

                if followers["pageInfo"] and followers["pageInfo"]["hasNextPage"]:
                    print("pagination")
                    has_next_page = followers["pageInfo"]["hasNextPage"]
                    cursor = followers["pageInfo"]["endCursor"]
                    save_progress(username, 'followers', cursor)
                    followersPaginationCounter = 0

                    while has_next_page:
                        if config["followersPaginationLoops"]["limitNumberOfLoops"] and config["followersPaginationLoops"]["limitCounter"] <= followersPaginationCounter:
                            break

                        check_rate_limit()

                        variables_query_followers = {
                            "username": username,
                            "cursor": cursor
                        }

                        response = requests.post(
                            GITHUB_API_ENDPOINT,
                            json = {
                                'query': PAGINATION_QUERY_FOLLOWERS,
                                "variables": variables_query_followers
                            },
                            headers = HEADERS
                        )
                        data_p = response.json()

                        batch_logins = []
                        nodes = data_p["data"]["user"]["followers"]["nodes"]
                        for node in nodes:
                            node_login = node["login"]
                            node_followers_total_count = node["followers"]["totalCount"]
                            node_following_total_count = node["following"]["totalCount"]

                            print(
                                "pagination followers",
                                " - ",
                                node_login,
                                " - ",
                                node_followers_total_count,
                                " - ",
                                node_following_total_count
                            )

                            if node_followers_total_count > 0 or node_following_total_count > 0:
                                # add to queue -> node["login"]
                                print("add to queue", node["login"])
                                batch_logins.append(node_login)
                        
                        enqueue_logins(batch_logins)
                        
                        has_next_page = data_p["data"]["user"]["followers"]["pageInfo"]["hasNextPage"]
                        cursor = data_p["data"]["user"]["followers"]["pageInfo"]["endCursor"]
                        followersPaginationCounter = followersPaginationCounter + 1

                        time.sleep(PAGINATION_LOOP_TIME_SLEEP)

            following = data["data"]["user"]["following"]
            if following:
                if following["nodes"]:
                    for node in following["nodes"]:
                        node_login = node["login"]
                        node_followers_total_count = node["followers"]["totalCount"]
                        node_following_total_count = node["following"]["totalCount"]

                        print(
                            "following",
                            " - ",
                            node["login"],
                            " - ",
                            node_followers_total_count,
                            " - ",
                            node_following_total_count
                        )
                else:
                    print("following nodes - empty")

                if following["pageInfo"] and following["pageInfo"]["hasNextPage"]:
                    has_next_page = following["pageInfo"]["hasNextPage"]
                    cursor = following["pageInfo"]["endCursor"]
                    save_progress(username, 'following', cursor)
                    followingPaginationCounter = 0

                    while has_next_page:
                        if config["followingsPaginationLoops"]["limitNumberOfLoops"] and config["followingsPaginationLoops"]["limitCounter"] <= followingPaginationCounter:
                            break

                        check_rate_limit()

                        variables_query_following = {
                            "username": username,
                            "cursor": cursor
                        }

                        response = requests.post(
                            GITHUB_API_ENDPOINT,
                            json = {
                                'query': PAGINATION_QUERY_FOLLOWING,
                                "variables": variables_query_following
                            },
                            headers = HEADERS
                        )
                        data_p = response.json()

                        batch_logins = []
                        nodes = data_p["data"]["user"]["following"]["nodes"]
                        for node in nodes:
                            node_login = node["login"]
                            node_followers_total_count = node["followers"]["totalCount"]
                            node_following_total_count = node["following"]["totalCount"]

                            print(
                                "following",
                                " - ",
                                node["login"],
                                " - ",
                                node_followers_total_count,
                                " - ",
                                node_following_total_count
                            )

                            if node_followers_total_count > 0 or node_following_total_count > 0:
                                # add to queue -> node["login"]
                                print("add to queue", node["login"])
                                batch_logins.append(node_login)

                        enqueue_logins(batch_logins)

                        has_next_page = data_p["data"]["user"]["following"]["pageInfo"]["hasNextPage"]
                        cursor = data_p["data"]["user"]["following"]["pageInfo"]["endCursor"]

                        followingPaginationCounter = followingPaginationCounter + 1

                        time.sleep(PAGINATION_LOOP_TIME_SLEEP)
                else:
                    print("following nextPage - no pagination")

        main_loop_counter = main_loop_counter + 1
        mark_user_done(username)
        save_progress(None, None, None)

    end_time = time.time()
    duration = end_time - start_time
    print(f"⏱️ Total execution time: {format_duration(duration)}")


def main():
    validate_github_token()
    worker()

if __name__ == "__main__":
    main()
