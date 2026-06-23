import { useState, type FormEvent } from 'react';

interface TodoFormProps {
  onAdd: (title: string) => void | Promise<void>;
}

export function TodoForm({ onAdd }: TodoFormProps) {
  const [title, setTitle] = useState('');

  const submit = async (event: FormEvent) => {
    event.preventDefault();
    const trimmed = title.trim();
    if (!trimmed) return;
    await onAdd(trimmed);
    setTitle('');
  };

  return (
    <form onSubmit={submit} className="todo-form">
      <input
        value={title}
        onChange={(event) => setTitle(event.target.value)}
        placeholder="Add a todo…"
        aria-label="New todo title"
      />
      <button type="submit">Add</button>
    </form>
  );
}
