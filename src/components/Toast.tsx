import { useEffect } from 'react';
import { hideToast, useToast } from '../state/toastStore';

const DURATION_MS = 3000;

export const Toast = () => {
  const { message, key } = useToast();

  useEffect(() => {
    if (!message) return;
    const id = window.setTimeout(hideToast, DURATION_MS);
    return () => window.clearTimeout(id);
  }, [message, key]);

  return (
    <div className="toast" role="status" aria-live="polite" data-visible={message !== null}>
      {message}
    </div>
  );
};
