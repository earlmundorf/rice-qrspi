"""Application entry point — exposes `app` for `uvicorn app.main:app`."""

from fastapi import FastAPI

from app.routers import todos

app = FastAPI(title="Todo API", version="0.1.0")
app.include_router(todos.router)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
