import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { App } from '../src/App';
import { t } from '../src/i18n';
import { useInstall } from '../src/state/installStore';
import { useMatch } from '../src/state/matchStore';
import { defaultSettings, useSettings } from '../src/state/settingsStore';

const initialMatch = useMatch.getState();

beforeEach(() => {
  history.replaceState(null, '', '/');
  useMatch.setState(initialMatch, true);
  // No camera in jsdom; the camera path is covered by tests/actions.test.ts and the browser check.
  useSettings.setState({ ...defaultSettings, videoEnable: false });
});

const score = (side: 'left' | 'right') => screen.getByLabelText(`${side} score`).textContent;

describe('scoring page', () => {
  it('scores, double-hits and resets', async () => {
    const user = userEvent.setup();
    render(<App />);
    expect(screen.getByText('03:00')).toBeInTheDocument();

    await user.click(screen.getByLabelText('left +1'));
    await user.click(screen.getByLabelText('left +1'));
    await user.click(screen.getByLabelText('right -1'));
    expect([score('left'), score('right')]).toEqual(['2', '-1']);

    await user.click(screen.getByText(t.doubleButtonText));
    expect([score('left'), score('right')]).toEqual(['3', '0']);

    await user.click(screen.getByText(t.resetButtonText));
    expect([score('left'), score('right')]).toEqual(['0', '0']);
  });

  it('sets the remaining time from the dialog', async () => {
    const user = userEvent.setup();
    render(<App />);
    await user.click(screen.getByText('03:00'));
    const dialog = screen.getByRole('dialog');
    const [minutes, seconds] = within(dialog).getAllByRole('combobox');
    await user.selectOptions(minutes!, '1');
    await user.selectOptions(seconds!, '30');
    await user.click(within(dialog).getByText(t.change));
    expect(screen.getByText('01:30')).toBeInTheDocument();
    expect(screen.getByText(t.timerChangedMessage)).toHaveAttribute('data-visible', 'true');
  });

  it('shows the match counter when enabled and hides the double button when disabled', async () => {
    useSettings.setState({ matchNumberCountEnable: true, doubleButtonEnable: false });
    const user = userEvent.setup();
    render(<App />);
    expect(screen.getByText('3 VS 6')).toBeInTheDocument();
    await user.click(screen.getByLabelText('match number +1'));
    expect(screen.getByText('1 VS 5')).toBeInTheDocument();
    expect(screen.queryByText(t.doubleButtonText)).not.toBeInTheDocument();
  });

  it('awards P-cards from the P button', async () => {
    useSettings.setState({ pCardEnable: true });
    const user = userEvent.setup();
    render(<App />);

    await user.click(screen.getByLabelText(t.pCardDialogTitle));
    await user.click(within(screen.getByRole('dialog')).getByText(t.pRedButtonText));
    expect([score('left'), score('right')]).toEqual(['1', '1']);
    expect(screen.getByLabelText('left P-red')).toBeInTheDocument();
    expect(screen.getByLabelText('right P-red')).toBeInTheDocument();

    // Tied: the referee picks the side with the higher initial seed; the other side loses.
    await user.click(screen.getByLabelText(t.pCardDialogTitle));
    const dialog = screen.getByRole('dialog');
    expect(within(dialog).getByText(t.pBlackTieMessage)).toBeInTheDocument();
    await user.click(within(dialog).getByText(t.left));
    expect(screen.getByLabelText('right P-black')).toBeInTheDocument();
    expect(screen.queryByLabelText('left P-black')).not.toBeInTheDocument();
  });

  it('hides the settings button while the clock runs', async () => {
    const user = userEvent.setup();
    render(<App />);
    await user.click(screen.getByText(new RegExp(t.startStopButtonText.replace('/', '\\/'))));
    expect(screen.queryByLabelText(t.settingsTitle)).not.toBeInTheDocument();
  });
});

describe('install banner', () => {
  afterEach(() => {
    useInstall.setState({ deferredPrompt: null, installed: false, bannerDismissed: false });
  });

  const offerPrompt = () => {
    const prompt = vi.fn(() => Promise.resolve());
    const event = Object.assign(new Event('beforeinstallprompt'), {
      prompt,
      userChoice: Promise.resolve({ outcome: 'accepted' as const, platform: 'web' }),
    });
    useInstall.setState({ deferredPrompt: event });
    return prompt;
  };

  it('installs from the banner when the browser offers a prompt', async () => {
    const prompt = offerPrompt();
    const user = userEvent.setup();
    render(<App />);

    await user.click(within(screen.getByRole('complementary')).getByText(t.installButtonText));
    expect(prompt).toHaveBeenCalledOnce();
    expect(screen.queryByRole('complementary')).not.toBeInTheDocument();
  });

  it('can be dismissed', async () => {
    offerPrompt();
    const user = userEvent.setup();
    render(<App />);
    await user.click(screen.getByLabelText(t.dismiss));
    expect(screen.queryByText(t.installBannerText)).not.toBeInTheDocument();
  });
});

describe('settings page', () => {
  it('navigates there and changes a setting', async () => {
    const user = userEvent.setup();
    render(<App />);
    await user.click(screen.getByLabelText(t.settingsTitle));
    expect(screen.getByRole('heading', { name: t.settingsTitle })).toBeInTheDocument();

    const group = screen.getByRole('group', { name: t.doubleButtonOptionText });
    await user.click(within(group).getByLabelText(t.disable));
    expect(useSettings.getState().doubleButtonEnable).toBe(false);

    await user.click(screen.getByLabelText(t.back));
    expect(screen.getByText('03:00')).toBeInTheDocument();
  });
});
