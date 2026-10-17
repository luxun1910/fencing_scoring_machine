/// <reference types="vite/client" />

interface ImportMetaEnv {
  /** Appended to the Start/Stop label (was the `appNamePrefix` dart-define). */
  readonly VITE_APP_NAME_PREFIX?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

/** Chromium's install prompt event; not in the standard DOM typings. */
interface BeforeInstallPromptEvent extends Event {
  prompt(): Promise<void>;
  readonly userChoice: Promise<{ outcome: 'accepted' | 'dismissed'; platform: string }>;
}

interface WindowEventMap {
  beforeinstallprompt: BeforeInstallPromptEvent;
}

interface Navigator {
  /** iOS Safari: true when launched from the home screen. */
  readonly standalone?: boolean;
}
