import * as actions from '../src/app/actions';
import * as camera from '../src/services/camera';
import { useMatch } from '../src/state/matchStore';
import { defaultSettings, useSettings } from '../src/state/settingsStore';

vi.mock('../src/services/camera', async (importOriginal) => {
  const real = await importOriginal<typeof camera>();
  return {
    ...real,
    startRecording: vi.fn(() => real.useCamera.setState({ isRecording: true })),
    stopRecording: vi.fn(async () => {
      real.useCamera.setState({ isRecording: false });
      return { blob: new Blob(['x']), url: 'blob:test', fileName: 'v.webm' };
    }),
  };
});

vi.mock('../src/services/videoSaver', () => ({ downloadVideo: vi.fn() }));

const initialMatch = useMatch.getState();
const isRunning = () => useMatch.getState().timer !== null;

beforeEach(() => {
  vi.useFakeTimers();
  useMatch.setState(initialMatch, true);
  useSettings.setState(defaultSettings);
  camera.useCamera.setState({ status: 'ready', isRecording: false });
  vi.clearAllMocks();
  URL.revokeObjectURL = vi.fn();
});

afterEach(() => vi.useRealTimers());

describe('pushTimer', () => {
  it('toggles the clock and recording together', async () => {
    actions.pushTimer();
    expect(isRunning()).toBe(true);
    expect(camera.startRecording).toHaveBeenCalledOnce();

    actions.pushTimer();
    expect(isRunning()).toBe(false);
    expect(camera.stopRecording).toHaveBeenCalledOnce();
    await vi.waitFor(() => expect(useMatch.getState().latestVideo?.url).toBe('blob:test'));
  });

  it('counts down from elapsed time and keeps it when stopped', () => {
    actions.pushTimer();
    vi.advanceTimersByTime(2500);
    actions.pushTimer();
    expect(useMatch.getState().secondsLeft).toBe(178);
  });

  it('does not record when video is disabled', () => {
    useSettings.setState({ videoEnable: false });
    actions.pushTimer();
    expect(isRunning()).toBe(true);
    expect(camera.startRecording).not.toHaveBeenCalled();
  });

  it('still runs the clock when the camera is not ready', () => {
    camera.useCamera.setState({ status: 'error' });
    actions.pushTimer();
    expect(isRunning()).toBe(true);
    expect(camera.startRecording).not.toHaveBeenCalled();
  });
});

describe('touches and reset halt the bout', () => {
  it.each([
    ['scoreUp', () => actions.scoreUp('left'), [1, 0]],
    ['scoreDown', () => actions.scoreDown('right'), [0, -1]],
    ['doubleHit', () => actions.doubleHit(), [1, 1]],
    ['resetAll', () => actions.resetAll(), [0, 0]],
  ] as const)('%s stops the clock and the recording', (_, act, score) => {
    actions.pushTimer();
    act();
    const s = useMatch.getState();
    expect(isRunning()).toBe(false);
    expect([s.leftScore, s.rightScore]).toEqual(score);
    expect(camera.stopRecording).toHaveBeenCalledOnce();
  });

  it('reset restores 03:00', () => {
    actions.setSecondsLeft(30);
    actions.resetAll();
    expect(useMatch.getState().secondsLeft).toBe(180);
  });
});

describe('match number', () => {
  it('changes without stopping the clock', () => {
    actions.pushTimer();
    actions.increaseMatchNumber();
    expect(useMatch.getState().matchNumber).toBe(2);
    expect(isRunning()).toBe(true);
    actions.setMatchNumber(42);
    expect(useMatch.getState().matchNumber).toBe(9);
  });
});

describe('recordings', () => {
  it('auto-saves when enabled and keeps only the latest video', async () => {
    const { downloadVideo } = await import('../src/services/videoSaver');
    useSettings.setState({ videoAutoSave: true });
    useMatch.setState({ latestVideo: { blob: new Blob(), url: 'blob:old', fileName: 'old.webm' } });

    actions.pushTimer();
    actions.pushTimer();
    await vi.waitFor(() => expect(downloadVideo).toHaveBeenCalledOnce());
    expect(URL.revokeObjectURL).toHaveBeenCalledWith('blob:old');
  });
});

describe('unwillingness to fight', () => {
  const fenceFor = (ms: number) => {
    vi.advanceTimersByTime(ms);
    useMatch.getState().syncTimer(performance.now());
    actions.checkNonCombativity();
  };

  it('halts the bout after one minute without a touch and asks for a P-card', () => {
    useSettings.setState({ pCardEnable: true });
    actions.pushTimer();
    fenceFor(59_500);
    expect(isRunning()).toBe(true);
    fenceFor(1_000);
    const s = useMatch.getState();
    expect(isRunning()).toBe(false);
    expect(s.pCardPrompt).toBe(true);
    expect(s.secondsLeft).toBe(120);
    expect(camera.stopRecording).toHaveBeenCalledOnce();
  });

  it('does nothing when the setting is off', () => {
    actions.pushTimer();
    fenceFor(61_000);
    expect(isRunning()).toBe(true);
    expect(useMatch.getState().pCardPrompt).toBe(false);
  });

  it('restarts the minute after a touch', () => {
    useSettings.setState({ pCardEnable: true });
    actions.pushTimer();
    fenceFor(40_000);
    actions.scoreUp('left');
    actions.pushTimer();
    fenceFor(40_000);
    expect(isRunning()).toBe(true);
  });

  it('awards P-red and P-black, and dismissing restarts the minute', () => {
    useSettings.setState({ pCardEnable: true });
    actions.pushTimer();
    fenceFor(60_000);
    actions.issuePRed();
    expect(useMatch.getState()).toMatchObject({
      leftScore: 1,
      rightScore: 1,
      pRed: true,
      pCardPrompt: false,
    });

    actions.pushTimer();
    fenceFor(60_000);
    actions.dismissPCard();
    actions.pushTimer();
    fenceFor(1_000);
    expect(isRunning()).toBe(true);

    actions.issuePBlack('right');
    expect(isRunning()).toBe(false);
    expect(useMatch.getState().pBlack).toBe('right');
    expect(actions.nextPCard()).toBeNull();
  });
});
