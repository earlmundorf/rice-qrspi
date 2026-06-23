"""In-memory data layer for todos.

Deliberately tiny — a real service would back this with a database and a
repository, but the QRSPI flow is identical either way. This module is the
'data' research layer for the example.
"""

from app.schemas import Todo, TodoCreate


class TodoStore:
    def __init__(self) -> None:
        self._todos: dict[int, Todo] = {}
        self._next_id = 1

    def list(self) -> list[Todo]:
        return list(self._todos.values())

    def add(self, data: TodoCreate) -> Todo:
        todo = Todo(id=self._next_id, title=data.title)
        self._todos[todo.id] = todo
        self._next_id += 1
        return todo

    def get(self, todo_id: int) -> Todo | None:
        return self._todos.get(todo_id)


# Single process-wide store for the example.
store = TodoStore()
