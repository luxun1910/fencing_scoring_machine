import { useSyncExternalStore } from 'react';

const subscribe = (onChange: () => void) => {
  document.addEventListener('visibilitychange', onChange);
  return () => document.removeEventListener('visibilitychange', onChange);
};

/** Whether the page is in the foreground (the web counterpart of the app lifecycle state). */
export const usePageVisible = () =>
  useSyncExternalStore(
    subscribe,
    () => document.visibilityState === 'visible',
    () => true,
  );
