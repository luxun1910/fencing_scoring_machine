import {
  dismissInstallBanner,
  listenForInstall,
  promptInstall,
  selectInstallMode,
  useInstall,
} from '../src/state/installStore';

const mode = () => selectInstallMode(useInstall.getState());

const fakePrompt = (outcome: 'accepted' | 'dismissed') => {
  const event = new Event('beforeinstallprompt', { cancelable: true }) as BeforeInstallPromptEvent;
  const prompt = vi.fn(() => Promise.resolve());
  Object.assign(event, { prompt, userChoice: Promise.resolve({ outcome, platform: 'web' }) });
  return { event, prompt };
};

const initial = useInstall.getState();
listenForInstall();

beforeEach(() => {
  useInstall.setState(initial, true);
  localStorage.clear();
  vi.restoreAllMocks();
});

afterEach(() => {
  vi.unstubAllGlobals();
});

describe('install', () => {
  it('offers nothing on a browser without an install prompt', () => {
    expect(mode()).toBe('none');
  });

  it('captures beforeinstallprompt and installs on accept', async () => {
    const { event, prompt } = fakePrompt('accepted');
    window.dispatchEvent(event);
    expect(event.defaultPrevented).toBe(true);
    expect(mode()).toBe('prompt');

    await promptInstall();
    expect(prompt).toHaveBeenCalledOnce();
    expect(useInstall.getState().deferredPrompt).toBeNull();
    expect(mode()).toBe('none');
  });

  it('drops the used prompt when the user declines', async () => {
    window.dispatchEvent(fakePrompt('dismissed').event);
    await promptInstall();
    expect(useInstall.getState().installed).toBe(false);
    expect(mode()).toBe('none');
  });

  it('hides after appinstalled', () => {
    window.dispatchEvent(fakePrompt('accepted').event);
    window.dispatchEvent(new Event('appinstalled'));
    expect(mode()).toBe('none');
  });

  it('shows instructions on iOS', () => {
    vi.spyOn(navigator, 'userAgent', 'get').mockReturnValue(
      'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 Version/18.0 Mobile Safari/604.1',
    );
    expect(mode()).toBe('ios');
  });

  it('offers nothing when already running as an installed app', () => {
    vi.spyOn(navigator, 'userAgent', 'get').mockReturnValue('iPhone');
    vi.stubGlobal('matchMedia', (query: string) => ({ matches: query === '(display-mode: standalone)' }));
    expect(mode()).toBe('none');
  });

  it('remembers that the banner was dismissed', () => {
    dismissInstallBanner();
    expect(useInstall.getState().bannerDismissed).toBe(true);
    expect(localStorage.getItem('fsm-install-dismissed')).toBe('1');
  });
});
