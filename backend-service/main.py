from fastapi import FastAPI, HTTPException, Request, WebSocket
from fastapi.responses import JSONResponse

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

import aiofiles
import asyncio
import httpx
import json
import os

app = FastAPI()

@app.get("/")
async def read_root():
    return {"message": "Hello, FastAPI with uv!"}

def load_json_data_file(filename):
    try:
        with open(filename, "r") as file:
            return json.load(file)
    except (FileNotFoundError, json.JSONDecodeError, PermissionError) as error:
        print(f"Error loading file '{filename}': {str(error)}")
        return None
    
@app.get("/trending-repositories")
def get_trending_repositories():
    repositories_data = load_json_data_file("repositories.json")
    if repositories_data is None:
        raise HTTPException(status_code=500, detail="Could not load trending repositories data.")
    return JSONResponse(content=repositories_data, status_code=200)

@app.get("/trending-developers")
def get_trending_developers():
    developers_data = load_json_data_file("developers.json")
    if developers_data is None:
        raise HTTPException(status_code=500, detail="Could not load trending developers data.")
    return JSONResponse(content=developers_data, status_code=200)

@app.get("/topics")
def get_topics():
    topics_data = load_json_data_file("topics.json")
    if topics_data is None:
        raise HTTPException(status_code=500, detail="Could not load topics data.")
    return JSONResponse(content=topics_data, status_code=200)

def update_rate_from_response(response: httpx.Response):
    try:
        remaining = int(response.headers.get("X-RateLimit-Remaining", 0))
        print(f"🔄 Aktualizuję rate limit: {remaining}")
        write_rate(remaining)
    except Exception as e:
        print(f"❌ Błąd przy aktualizacji rate limitu: {e}")

@app.post("/graphql/pinned-repos")
async def get_pinned_repositories(request: Request):
    GITHUB_GRAPHQL_URL = "https://api.github.com/graphql"
    GRAPHQL_QUERY = """
    query($username: String!) {
        user(login: $username) {
            pinnedItems(first: 6, types: [REPOSITORY]) {
                nodes {
                    ... on Repository {
                    name
                    description
                    url
                    stargazerCount
                    owner {
                        login
                        avatarUrl
                    }
                    }
                }
            }
        }
    }
    """

    print("REQUEST")
    print(await request.json())
    try:
        body = await request.json()
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid JSON body: {e}")
    
    token = body.get("token")
    username = body.get("username")
    
    print("START")
    print(token)
    print(username)

    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/json"
    }

    variables = {
        "username": username
    }

    async with httpx.AsyncClient() as client:
        response = await client.post(
            GITHUB_GRAPHQL_URL,
            json={ "query": GRAPHQL_QUERY, "variables": variables },
            headers=headers
        )

    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail=response.json())
    
    # update_rate_from_response(response)
    
    data = response.json()
    repos = data["data"]["user"]["pinnedItems"]["nodes"]
    print(repos)

    return repos

# @app.post("/update-rate")
# async def update_rate(request: Request):
#     return {
#         "success": True
#     }

# @app.get("/current-rate")
# async def current_rate():
#     return {
#         "data": "1000"
#     }

def read_rate():
    data = load_json_data_file("rate.json")
    return data.get("remaining")

def write_rate(value):
    with open("rate.json", "w") as f:
        json.dump({"remaining": value}, f)

async def async_write_rate(value):
    async with aiofiles.open("rate.json", "w") as f:
        await f.write(json.dumps({"remaining": value}))

# async def fetch_and_store():

# Monitorowanie zmian w pliku rate.json
# Handler watchdoga – działa w osobnym wątku
class RateFileHandler(FileSystemEventHandler):
    def __init__(self, websocket: WebSocket, loop: asyncio.AbstractEventLoop):
        self.websocket = websocket
        self.loop = loop

    def on_modified(self, event):
        if event.is_directory:
            return
        if os.path.basename(event.src_path) == "rate.json":
            data = load_json_data_file("rate.json")
            if data:
                print("🔁 Wysyłam zmienione dane do WebSocketa:", data)
                coroutine = self.websocket.send_json(data)
                asyncio.run_coroutine_threadsafe(coroutine, self.loop)

# Endpoint WebSocket
@app.websocket("/ws/rate")
async def websocket_rate(websocket: WebSocket):
    await websocket.accept()
    print("✅ WebSocket połączony")

    # Wyślij dane początkowe z pliku
    data = load_json_data_file("rate.json")
    if data:
        await websocket.send_json(data)

    # Pobierz aktualną pętlę asyncio (z głównego wątku)
    loop = asyncio.get_running_loop()

    # Obserwator pliku
    handler = RateFileHandler(websocket, loop)
    observer = Observer()
    observer.schedule(handler, path=".", recursive=False)
    observer.start()

    try:
        while True:
            await asyncio.sleep(1)
    except Exception as e:
        print("❌ Błąd WebSocket:", e)
    finally:
        print("🛑 Zamykam observer i WebSocket")
        observer.stop()
        observer.join()

def update_rate_from_response(response: httpx.Response):
    try:
        remaining = int(response.headers.get("X-RateLimit-Remaining", 0))
        write_rate(remaining)
    except Exception as e:
        print(f"❌ Błąd podczas aktualizacji rate limitu: {e}")


@app.post("/update-rate")
async def update_rate(request: Request):
    body = await request.json()
    print(body)
    # remaining_header = request.headers
    # print(remaining_header)
    remaining = body.get("remaining", 0)

    write_rate(remaining)

    # async with httpx.AsyncClient() as client:
    #     response = await client.get(
    #         "https://api.github.com/rate_limit",
    #         headers={
    #             "Authorization": f"token token"
    #         }
    #     )

    # if response.status_code != 200:
    #     raise HTTPException(status_code=response.status_code, detail=response.json())
    
    # rem = int(response.headers.get("X-RateLimit-Remaining", 0))

    return {
        "message": "rem"
    }

# @app.route("/current-rate", methods=["GET"])
# def current_rate():
#     return jsonify(rate_data)

@app.post("/log-request")
async def log_request(request: Request):
    data = await request.json()
    print("LOG REQUEST")
    print(data)
    # with open("requests_log.json", "a") as f:
    #     f.write(json.dumps(data) + "\n")
    # return jsonify({"status": "ok"})
