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

    redis_client = get_redis_connection()

    while True:
        result = redis_client.blpop(QUEUE_NAME, timeout=0)
        _, username = result

        # print(f"➡️ Got login from Redis: {username}")
        print(f"[{datetime.now().strftime('%H:%M:%S')}] ➡️ Got login from Redis: {username}")
        time.sleep(0.5)

if __name__ == "__main__":
    consumer()
    # usr = fetch_github_user("jakubgania")
    # print(usr)