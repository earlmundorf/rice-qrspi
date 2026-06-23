"""Pydantic request/response models for the Todo API."""

from pydantic import BaseModel


class TodoCreate(BaseModel):
    """Payload for creating a todo."""

    title: str


class Todo(BaseModel):
    """A todo item as returned by the API."""

    id: int
    title: str
    completed: bool = False
