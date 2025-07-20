from datetime import datetime
import requests
import time
import os

GITHUB_RATE_LIMIT_ENDPOINT = "https://api.github.com/rate_limit"
GITHUB_API_TOKEN=os.environ.get("GITHUB_API_TOKEN")
HEADERS = {
    "Authorization": f"Bearer {GITHUB_API_TOKEN}"
}

def get_rate_limit():
    response = requests.get(GITHUB_RATE_LIMIT_ENDPOINT, headers=HEADERS)
    data = response.json()
    remaining = data["resources"]["graphql"]["remaining"]
    reset_time = data["resources"]["graphql"]["reset"]
    return remaining, reset_time

def wait_for_reset(reset_time):
    while True:
        current_time = time.time()
        seconds_left = int(reset_time - current_time)

        if seconds_left <= 0:
            print("✅ Limit zresetowany, kontynuuję...")
            break

        # Formatowanie czasu końcowego
        reset_time_str = datetime.fromtimestamp(reset_time).strftime('%Y-%m-%d %H:%M:%S')

        # Odliczanie
        print(f"⏳ Do resetu: {seconds_left} sek. (o {reset_time_str})", end='\r')

        time.sleep(1)

def check_rate_limit():
    remaining, reset_time = get_rate_limit()
    reset_datetime = datetime.fromtimestamp(reset_time).strftime('%Y-%m-%d %H:%M:%S')

    if remaining == 0:
        wait_for_reset(reset_time)
    else:
        print(" ")
        print(f"api rate limit: {remaining}")
        print(f"api reset time (unix): {reset_time}")
        print(f"api reset time (local): {reset_datetime}")

def worker():
    print("✅ start worker")
    print("token: ", GITHUB_API_TOKEN)

    check_rate_limit()

def main():
    worker()

if __name__ == "__main__":
    main()
