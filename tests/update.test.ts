import { initialMatchState } from '../src/domain/scoring';
import { useMatch } from '../src/state/matchStore';
import { onUpdateFound, useUpdate } from '../src/state/updateStore';

const initialMatch = useMatch.getState();
const initialUpdate = useUpdate.getState();

beforeEach(() => {
  useMatch.setState(initialMatch, true);
  useUpdate.setState(initialUpdate, true);
});

describe('update', () => {
  it('applies a new version at once while the match is untouched', () => {
    const apply = vi.fn(() => Promise.resolve());
    onUpdateFound(apply);
    expect(apply).toHaveBeenCalledOnce();
    expect(useUpdate.getState().needRefresh).toBe(false);
  });

  it('waits for the user once a bout has started', async () => {
    useMatch.setState({ leftScore: initialMatchState.leftScore + 1 });
    const apply = vi.fn(() => Promise.resolve());
    onUpdateFound(apply);
    expect(apply).not.toHaveBeenCalled();
    expect(useUpdate.getState().needRefresh).toBe(true);

    await useUpdate.getState().applyUpdate();
    expect(apply).toHaveBeenCalledOnce();
  });

  it('never reloads under a running clock', () => {
    useMatch.getState().startTimer(Date.now());
    const apply = vi.fn(() => Promise.resolve());
    onUpdateFound(apply);
    expect(apply).not.toHaveBeenCalled();
  });
});
