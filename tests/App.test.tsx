import { render, screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { App } from '../src/App';
import { t } from '../src/i18n';
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

  it('hides the settings button while the clock runs', async () => {
    const user = userEvent.setup();
    render(<App />);
    await user.click(screen.getByText(new RegExp(t.startStopButtonText.replace('/', '\\/'))));
    expect(screen.queryByLabelText(t.settingsTitle)).not.toBeInTheDocument();
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
