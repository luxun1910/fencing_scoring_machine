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

export const locale = resolveLocale(typeof navigator === 'undefined' ? [] : navigator.languages);

/** Messages for the current locale. The language never changes while the page is open. */
export const t: Messages = catalogs[locale];
