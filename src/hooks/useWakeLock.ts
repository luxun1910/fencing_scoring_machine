import { useEffect } from 'react';

/** Keeps the screen on while `active` (and the page is visible). No-op where unsupported. */
export const useWakeLock = (active: boolean) => {
  useEffect(() => {
    if (!active || !('wakeLock' in navigator)) return;
    let sentinel: WakeLockSentinel | null = null;
    let cancelled = false;

    const request = () => {
      if (document.visibilityState !== 'visible') return;
      navigator.wakeLock
        .request('screen')
        .then((s) => {
          if (cancelled) void s.release();
          else sentinel = s;
        })
        .catch(() => {
          // Denied (e.g. battery saver); the app works without it.
        });
    };

    // The browser drops the lock when the page is hidden, so take it again on return.
    document.addEventListener('visibilitychange', request);
    request();
    return () => {
      cancelled = true;
      document.removeEventListener('visibilitychange', request);
      void sentinel?.release();
    };
  }, [active]);
};
