from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse

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