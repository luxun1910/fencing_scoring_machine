/** Remaining seconds at the start of a bout and after a reset (3 minutes). */
export const INITIAL_SECONDS = 180;

export const MIN_MATCH_NUMBER = 1;
export const MAX_MATCH_NUMBER = 9;

export type Side = 'left' | 'right';

/** Score, clock and match counter of a bout. Every transition below is a pure function. */
export interface MatchState {
  leftScore: number;
  rightScore: number;
  secondsLeft: number;
  matchNumber: number;
}

export const initialMatchState: MatchState = {
  leftScore: 0,
  rightScore: 0,
  secondsLeft: INITIAL_SECONDS,
  matchNumber: MIN_MATCH_NUMBER,
};

const scoreKey = (side: Side) => (side === 'left' ? 'leftScore' : 'rightScore');

/** Scores are allowed to go negative, as in the original app. */
export const scoreUp = (s: MatchState, side: Side): MatchState => ({
  ...s,
  [scoreKey(side)]: s[scoreKey(side)] + 1,
});

export const scoreDown = (s: MatchState, side: Side): MatchState => ({
  ...s,
  [scoreKey(side)]: s[scoreKey(side)] - 1,
});

export const doubleHit = (s: MatchState): MatchState => scoreUp(scoreUp(s, 'left'), 'right');

/** Resets scores and clock. The match number is kept. */
export const resetBout = (s: MatchState): MatchState => ({
  ...s,
  leftScore: 0,
  rightScore: 0,
  secondsLeft: INITIAL_SECONDS,
});

/** Counts down one second, stopping at zero. */
export const tick = (s: MatchState): MatchState =>
  s.secondsLeft > 0 ? { ...s, secondsLeft: s.secondsLeft - 1 } : s;

export const setSecondsLeft = (s: MatchState, seconds: number): MatchState => ({
  ...s,
  secondsLeft: Math.max(0, Math.trunc(seconds)),
});

export const clampMatchNumber = (n: number): number =>
  Math.min(MAX_MATCH_NUMBER, Math.max(MIN_MATCH_NUMBER, Math.trunc(n)));

export const setMatchNumber = (s: MatchState, n: number): MatchState => ({
  ...s,
  matchNumber: clampMatchNumber(n),
});

export const increaseMatchNumber = (s: MatchState): MatchState => setMatchNumber(s, s.matchNumber + 1);

export const decreaseMatchNumber = (s: MatchState): MatchState => setMatchNumber(s, s.matchNumber - 1);
