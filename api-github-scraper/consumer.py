import os
import time
import redis
import requests
import psycopg

from datetime import datetime

QUEUE_NAME = "github_logins_queue"
POSTGRES_DSN = os.getenv("POSTGRES_DSN", "postgresql://postgres:postgres@localhost:5432/postgres")

GITHUB_API_ENDPOINT = "https://api.github.com/graphql"
GITHUB_API_TOKEN=os.environ.get("GITHUB_API_TOKEN")
HEADERS = {
    "Authorization": f"Bearer {GITHUB_API_TOKEN}"
}

BASIC_USER_QUERY = """
query($username: String!) {
    user(login: $username) {
        login
        name
        bio
        company
        location
        createdAt
        followers {
            totalCount
        }
        following {
            totalCount
        }
    }
}
"""

def get_redis_connection():
    return redis.Redis(host='localhost', port=6379, db=0, decode_responses=True)

def wait_for_postgres():
    """Czeka aż Postgres będzie dostępny."""
    while True:
        try:
            with psycopg.connect(POSTGRES_DSN) as conn:
                with conn.cursor() as cur:
                    cur.execute("SELECT 1;")
                    return
        except Exception as e:
            print(f"⏳ Waiting for Postgres... ({e})")
            time.sleep(2)

def init_db():
    """init db"""
    with psycopg.connect(POSTGRES_DSN) as conn:
        with conn.cursor() as cur:
            cur.execute("""
            CREATE TABLE IF NOT EXISTS users (
                login TEXT PRIMARY KEY,
                name TEXT,
                bio TEXT,
                company TEXT,
                location TEXT,
                created_at TIMESTAMP,
                followers_count INT,
                following_count INT,
                status TEXT DEFAULT 'pending'
            );
            """)
            cur.execute("CREATE INDEX IF NOT EXISTS idx_users_company ON users (company);")
            cur.execute("CREATE INDEX IF NOT EXISTS idx_users_location ON users (location);")

            # Table scraper_progress
            cur.execute("""
            CREATE TABLE IF NOT EXISTS scraper_progress (
                id SERIAL PRIMARY KEY,
                current_login TEXT,
                current_mode TEXT,        -- 'followers' albo 'following'
                current_cursor TEXT,
                last_update TIMESTAMP DEFAULT now()
            );
            """)

            # Make sure there is a start record with id=1
            cur.execute("""
            INSERT INTO scraper_progress (id, current_login, current_mode, current_cursor)
            VALUES (1, NULL, NULL, NULL)
            ON CONFLICT (id) DO NOTHING;
            """)

            conn.commit()

def user_exists(login: str) -> bool:
    """check usr"""
    with psycopg.connect(POSTGRES_DSN) as coon:
        with coon.cursor() as cur:
            cur.execute("SELECT 1 FROM users WHERE login = %s LIMIT 1;", (login,))
            return cur.fetchone() is not None
        
def save_user(user_data: dict):
    """save usr to db"""
    with psycopg.connect(POSTGRES_DSN) as conn:
        with conn.cursor() as cur:
            cur.execute("""
                INSERT INTO users (login, name, bio, company, location, created_at, followers_count, following_count, status)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 'pending')
                ON CONFLICT (login) DO NOTHING;
            """, (
                user_data["login"],
                user_data["name"],
                user_data["bio"],
                user_data["company"],
                user_data["location"],
                user_data["createdAt"],
                user_data["followers"]["totalCount"],
                user_data["following"]["totalCount"]
            ))
            conn.commit()

def fetch_github_user(username: str):
    variables = {"username": username}

    try:
        response = requests.post(
            GITHUB_API_ENDPOINT,
            headers=HEADERS,
            json={
                "query": BASIC_USER_QUERY,
                "variables": variables
            },
            timeout=5
        )

        response.raise_for_status()
        data = response.json()

        if "errors" in data:
            print(f"⚠️ GitHub API error for {username}: {data['errors'][0]['message']}")
            return None
        
        return data["data"]["user"]
    except requests.RequestException as e:
        print(f"❌ Request error for {username}: {e}")
        return None

def consumer():
    print("✅ Starting GitHub consumer...")

    wait_for_postgres()
    init_db()

    redis_client = get_redis_connection()

    while True:
        result = redis_client.blpop(QUEUE_NAME, timeout=0)
        _, username = result

        # print(f"➡️ Got login from Redis: {username}")
        print(f"[{datetime.now().strftime('%H:%M:%S')}] ➡️ Got login from Redis: {username}")
        
        
         # 1. Check if the user is in the database
        if user_exists(username):
            print(f"↩️ User {username} already in DB, skipping...")
            continue

        # 2. Fetch data from GitHub
        user_data = fetch_github_user(username)
        if not user_data:
            print(f"⚠️ No data for user {username}")
            continue

        # 3. Save to database
        save_user(user_data)
        print(f"💾 Saved {username} to DB")
        
        time.sleep(0.5)

if __name__ == "__main__":
    consumer()
    # usr = fetch_github_user("jakubgania")
    # print(usr)