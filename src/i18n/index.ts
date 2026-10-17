import { useSettings } from '../state/settingsStore';
import { en, type Messages } from './en';
import { fr } from './fr';
import { ja } from './ja';

const catalogs = { en, ja, fr } satisfies Record<string, Messages>;
export type Locale = keyof typeof catalogs;

/** Picks the first supported language from the browser's preferences, falling back to English. */
export const resolveLocale = (languages: readonly string[]): Locale => {
  for (const lang of languages) {
    const base = lang.toLowerCase().split('-')[0];
    if (base && base in catalogs) return base as Locale;
  }
  return 'en';
};

/** The language chosen in settings, or the browser's preference when set to auto. */
export const currentLocale = (): Locale => {
  const language = useSettings.getState().language;
  if (language !== 'auto') return language;
  return resolveLocale(typeof navigator === 'undefined' ? [] : navigator.languages);
};

/**
 * Messages for the current locale. Each lookup reads the current language, so read it at
 * render time (not at module scope); App remounts the pages when the language changes.
 */
export const t: Messages = new Proxy({} as Messages, {
  get: (_, key) => catalogs[currentLocale()][key as keyof Messages],
});
