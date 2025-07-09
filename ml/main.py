from fastapi import FastAPI, Request
from AI.AI import process_student
import json


with open("database/professions.json", "r", encoding="utf-8") as f:
    PROFESSIONS = json.load(f)

app = FastAPI()

@app.post("/recommend")
async def recommend(req: Request):
    student = await req.json()
    top5 = process_student(student, PROFESSIONS)
    return top5
