"""Todo endpoints — the 'routers' research layer for the example."""

from fastapi import APIRouter, HTTPException

from app.schemas import Todo, TodoCreate
from app.store import store

router = APIRouter(prefix="/todos", tags=["todos"])


@router.get("")
def list_todos() -> list[Todo]:
    return store.list()


@router.post("", status_code=201)
def create_todo(data: TodoCreate) -> Todo:
    return store.add(data)


@router.get("/{todo_id}")
def get_todo(todo_id: int) -> Todo:
    todo = store.get(todo_id)
    if todo is None:
        raise HTTPException(status_code=404, detail="todo not found")
    return todo
