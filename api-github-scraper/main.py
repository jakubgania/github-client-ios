from datetime import datetime
import requests
import socket
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

def worker():
    start_time = time.time()

    print("✅ start worker")
    print("token: ", GITHUB_API_TOKEN)

    check_rate_limit()
    print("🚀 so let's move on!")

    check_services_running()

    # get login to init script
    # 1 check redis 
    # 2 check file
    # start main loops

    end_time = time.time()
    duration = end_time - start_time
    print(f"⏱️ Total execution time: {format_duration(duration)}")


def main():
    worker()

if __name__ == "__main__":
    main()
