import { create } from 'zustand';
import { safeLocalStorage } from './settingsStore';

/**
 * How the app can be installed here:
 * - `prompt`: the browser offered `beforeinstallprompt` (Chrome/Edge on Android and desktop).
 * - `ios`: Safari on iPhone/iPad, which has no install API; the user adds it from the share sheet.
 * - `none`: already installed, or the browser offers no way we can drive.
 */
export type InstallMode = 'prompt' | 'ios' | 'none';

const DISMISSED_KEY = 'fsm-install-dismissed';

interface InstallState {
  deferredPrompt: BeforeInstallPromptEvent | null;
  /** Set by `appinstalled`, since the page keeps running in the browser tab afterwards. */
  installed: boolean;
  bannerDismissed: boolean;
}

export const useInstall = create<InstallState>()(() => ({
  deferredPrompt: null,
  installed: false,
  bannerDismissed: safeLocalStorage.getItem(DISMISSED_KEY) === '1',
}));

export const isStandalone = () =>
  window.matchMedia?.('(display-mode: standalone)').matches ||
  window.matchMedia?.('(display-mode: fullscreen)').matches ||
  navigator.standalone === true;

/** iPhone/iPod, or iPadOS which reports itself as a Mac but has a touch screen. */
export const isIos = () =>
  /iPhone|iPad|iPod/.test(navigator.userAgent) ||
  (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);

export const selectInstallMode = (s: InstallState): InstallMode => {
  if (s.installed || isStandalone()) return 'none';
  if (s.deferredPrompt) return 'prompt';
  if (isIos()) return 'ios';
  return 'none';
};

/** Shows the browser's install dialog. Only meaningful in `prompt` mode. */
export const promptInstall = async () => {
  const prompt = useInstall.getState().deferredPrompt;
  if (!prompt) return;
  // A deferred prompt can only be used once, whatever the user answers.
  useInstall.setState({ deferredPrompt: null });
  await prompt.prompt();
  const { outcome } = await prompt.userChoice;
  if (outcome === 'accepted') useInstall.setState({ installed: true });
};

export const dismissInstallBanner = () => {
  safeLocalStorage.setItem(DISMISSED_KEY, '1');
  useInstall.setState({ bannerDismissed: true });
};

/** Registered at startup, before React mounts, so an early `beforeinstallprompt` is not missed. */
export const listenForInstall = () => {
  window.addEventListener('beforeinstallprompt', (e) => {
    // Keep the browser's own mini-infobar quiet; the app shows its own button instead.
    e.preventDefault();
    useInstall.setState({ deferredPrompt: e });
  });
  window.addEventListener('appinstalled', () => {
    useInstall.setState({ deferredPrompt: null, installed: true });
  });
};
