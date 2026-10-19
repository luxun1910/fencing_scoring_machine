import { create } from 'zustand';
import { initialMatchState, type MatchState } from '../domain/scoring';
import { useMatch } from './matchStore';

interface UpdateState {
  /** A new version is installed and waiting; applying it reloads the page. */
  needRefresh: boolean;
  applyUpdate: () => Promise<void>;
}

export const useUpdate = create<UpdateState>()(() => ({
  needRefresh: false,
  applyUpdate: async () => {},
}));

/** Nothing would be lost by reloading: no bout in progress and no recording to replay. */
export const isMatchUntouched = () => {
  const s = useMatch.getState();
  if (s.timer || s.latestVideo) return false;
  return (Object.keys(initialMatchState) as (keyof MatchState)[]).every((k) => s[k] === initialMatchState[k]);
};

/**
 * A new version never reloads the page by itself mid-bout (the score is not persisted):
 * it is applied at once only while the match is untouched, otherwise the scoreboard offers it.
 */
export const onUpdateFound = (applyUpdate: () => Promise<void>) => {
  if (isMatchUntouched()) void applyUpdate();
  else useUpdate.setState({ needRefresh: true, applyUpdate });
};
