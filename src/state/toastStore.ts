import { create } from 'zustand';

interface ToastState {
  message: string | null;
  /** Bumped on every show so the same message twice restarts the timeout. */
  key: number;
}

export const useToast = create<ToastState>()(() => ({ message: null, key: 0 }));

export const showToast = (message: string) => useToast.setState((s) => ({ message, key: s.key + 1 }));
export const hideToast = () => useToast.setState({ message: null });
