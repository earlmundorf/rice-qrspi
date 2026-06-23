import { TodoForm } from './components/TodoForm';
import { TodoList } from './components/TodoList';
import { useTodos } from './hooks/useTodos';
import './App.css';

export function App() {
  const { todos, loading, error, add } = useTodos();

  return (
    <main className="app">
      <h1>Todos</h1>
      <TodoForm onAdd={add} />
      {loading && <p>Loading…</p>}
      {error && <p className="error">{error}</p>}
      {!loading && !error && <TodoList todos={todos} />}
    </main>
  );
}
