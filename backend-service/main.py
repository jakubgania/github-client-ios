from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse

import httpx
import json

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
    
    data = response.json()
    repos = data["data"]["user"]["pinnedItems"]["nodes"]
    print(repos)

    return repos