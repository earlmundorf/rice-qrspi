"""Unit tests for the Todo API (via Starlette's TestClient)."""

from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health() -> None:
    assert client.get("/health").json() == {"status": "ok"}


def test_create_and_list_todo() -> None:
    created = client.post("/todos", json={"title": "write docs"})
    assert created.status_code == 201
    body = created.json()
    assert body["title"] == "write docs"
    assert body["completed"] is False

    listed = client.get("/todos").json()
    assert any(t["id"] == body["id"] for t in listed)


def test_get_missing_todo_returns_404() -> None:
    assert client.get("/todos/99999").status_code == 404
