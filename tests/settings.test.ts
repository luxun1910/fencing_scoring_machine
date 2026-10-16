import { resolveLocale } from '../src/i18n';
import { en } from '../src/i18n/en';
import { fr } from '../src/i18n/fr';
import { ja } from '../src/i18n/ja';
import { defaultSettings, useSettings } from '../src/state/settingsStore';

describe('settings', () => {
  it('has the original defaults', () => {
    expect(defaultSettings).toEqual({
      videoEnable: true,
      videoAutoSave: false,
      videoPreviewSize: 2,
      videoPreviewPosition: 'right',
      doubleButtonEnable: true,
      matchNumberCountEnable: false,
    });
  });

  it('persists changes to localStorage', () => {
    useSettings.getState().set('doubleButtonEnable', false);
    useSettings.getState().set('videoPreviewSize', 3);
    const saved = JSON.parse(localStorage.getItem('fsm-settings') ?? '{}');
    expect(saved.state).toMatchObject({ doubleButtonEnable: false, videoPreviewSize: 3 });
    expect(saved.state).not.toHaveProperty('set');
  });
});

describe('i18n', () => {
  it('picks the first supported language', () => {
    expect(resolveLocale(['de-DE', 'ja-JP', 'en'])).toBe('ja');
    expect(resolveLocale(['fr-CA'])).toBe('fr');
    expect(resolveLocale(['zh-CN'])).toBe('en');
    expect(resolveLocale([])).toBe('en');
  });

  it('translates every key', () => {
    for (const catalog of [ja, fr]) {
      expect(Object.keys(catalog).sort()).toEqual(Object.keys(en).sort());
      for (const value of Object.values(catalog)) expect(value).not.toBe('');
    }
  });
});
