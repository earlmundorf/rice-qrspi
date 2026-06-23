import type { Todo } from '../types';

// The designated API boundary (apiBoundary in config). Components and hooks
// never hold state directly — every read/write goes through this module.
// Backed by an in-memory list for the demo; swap the bodies for real fetch()
// calls and nothing upstream changes.

let todos: Todo[] = [
  { id: 1, title: 'Read the QRSPI walkthrough', completed: false },
  { id: 2, title: 'Run /cq:go TODO-1', completed: false },
];
let nextId = 3;

const delay = () => new Promise((resolve) => setTimeout(resolve, 150));

export async function listTodos(): Promise<Todo[]> {
  await delay();
  return [...todos];
}

export async function createTodo(title: string): Promise<Todo> {
  await delay();
  const todo: Todo = { id: nextId++, title, completed: false };
  todos = [...todos, todo];
  return todo;
}
