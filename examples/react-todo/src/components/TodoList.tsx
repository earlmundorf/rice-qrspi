import type { Todo } from '../types';

interface TodoListProps {
  todos: Todo[];
}

export function TodoList({ todos }: TodoListProps) {
  if (todos.length === 0) {
    return <p className="empty">No todos yet.</p>;
  }
  return (
    <ul className="todo-list">
      {todos.map((todo) => (
        <li key={todo.id} className={todo.completed ? 'done' : undefined}>
          {todo.title}
        </li>
      ))}
    </ul>
  );
}
