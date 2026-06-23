import { useCallback, useEffect, useState } from 'react';
import type { Todo } from '../types';
import { createTodo, listTodos } from '../services/api';

// The 'state' research layer: owns the todo list, loading, and error state,
// and talks to the API boundary. Components consume this, not the API directly.
export function useTodos() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      setTodos(await listTodos());
    } catch {
      setError('Failed to load todos');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  const add = useCallback(async (title: string) => {
    const todo = await createTodo(title);
    setTodos((prev) => [...prev, todo]);
  }, []);

  return { todos, loading, error, add, refresh };
}
