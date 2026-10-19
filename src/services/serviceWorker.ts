import { registerSW } from 'virtual:pwa-register';
import { onUpdateFound } from '../state/updateStore';

/** How often an open app asks the server for a new version; a scoreboard can stay open for hours. */
const CHECK_INTERVAL_MS = 60 * 60 * 1000;

/** Registers the service worker and keeps checking for new deploys while the app stays open. */
export const registerServiceWorker = () => {
  const updateSW = registerSW({
    onNeedRefresh: () => onUpdateFound(() => updateSW(true)),
    onRegisteredSW: (_swUrl, registration) => {
      if (!registration) return;
      const check = () => {
        if (registration.installing || !navigator.onLine) return;
        registration.update().catch(() => {});
      };
      window.setInterval(check, CHECK_INTERVAL_MS);
      // Coming back to the app is the moment a user expects the latest version.
      document.addEventListener('visibilitychange', () => {
        if (document.visibilityState === 'visible') check();
      });
    },
  });
};
