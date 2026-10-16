/// <reference types="vite/client" />

interface ImportMetaEnv {
  /** Appended to the Start/Stop label (was the `appNamePrefix` dart-define). */
  readonly VITE_APP_NAME_PREFIX?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
