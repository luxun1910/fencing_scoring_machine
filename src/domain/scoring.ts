/** Remaining seconds at the start of a bout and after a reset (3 minutes). */
export const INITIAL_SECONDS = 180;

export const MIN_MATCH_NUMBER = 1;
export const MAX_MATCH_NUMBER = 9;

/** Fencing time without a touch that counts as unwillingness to fight (FIE t.124). */
export const NON_COMBATIVITY_SECONDS = 60;

export type Side = 'left' | 'right';

export type PCard = 'red' | 'black';

/** Score, clock and match counter of a bout. Every transition below is a pure function. */
export interface MatchState {
  leftScore: number;
  rightScore: number;
  secondsLeft: number;
  matchNumber: number;
  /** secondsLeft when the non-combativity minute last started again. */
  idleFromSeconds: number;
  /** A P-red card (a penalty touch to each side) was awarded to both sides. */
  pRed: boolean;
  /** The side that lost the bout by a P-black card. */
  pBlack: Side | null;
}

export const initialMatchState: MatchState = {
  leftScore: 0,
  rightScore: 0,
  secondsLeft: INITIAL_SECONDS,
  matchNumber: MIN_MATCH_NUMBER,
  idleFromSeconds: INITIAL_SECONDS,
  pRed: false,
  pBlack: null,
};

const scoreKey = (side: Side) => (side === 'left' ? 'leftScore' : 'rightScore');

const opposite = (side: Side): Side => (side === 'left' ? 'right' : 'left');

/** The minute starts again after each hit, hit annulled, penalty hit and period/relay start. */
export const restartMinute = (s: MatchState): MatchState => ({ ...s, idleFromSeconds: s.secondsLeft });

/** Fencing time since the non-combativity minute last started again. */
export const idleSeconds = (s: MatchState): number => s.idleFromSeconds - s.secondsLeft;

const addScore = (s: MatchState, side: Side, delta: number): MatchState => ({
  ...s,
  [scoreKey(side)]: s[scoreKey(side)] + delta,
});

/** Scores are allowed to go negative, as in the original app. */
export const scoreUp = (s: MatchState, side: Side): MatchState => restartMinute(addScore(s, side, 1));

export const scoreDown = (s: MatchState, side: Side): MatchState => restartMinute(addScore(s, side, -1));

export const doubleHit = (s: MatchState): MatchState => scoreUp(scoreUp(s, 'left'), 'right');

/** Resets scores, clock and P-cards. The match number is kept. */
export const resetBout = (s: MatchState): MatchState => ({
  ...s,
  leftScore: 0,
  rightScore: 0,
  secondsLeft: INITIAL_SECONDS,
  idleFromSeconds: INITIAL_SECONDS,
  pRed: false,
  pBlack: null,
});

/** No P-card may be awarded at 14-14 (individual) or 44-44 (team). */
const pCardsBlocked = (s: MatchState, isTeam: boolean) => {
  const last = isTeam ? 44 : 14;
  return s.leftScore === last && s.rightScore === last;
};

/** The P-card the next minute of unwillingness to fight leads to, or null when none can be awarded. */
export const nextPCard = (s: MatchState, isTeam: boolean): PCard | null => {
  if (s.pBlack || pCardsBlocked(s, isTeam)) return null;
  return s.pRed ? 'black' : 'red';
};

/** One minute without a touch. t.124 does not apply to a tie at the end of regulation time. */
export const isNonCombativity = (s: MatchState, isTeam: boolean): boolean =>
  idleSeconds(s) >= NON_COMBATIVITY_SECONDS &&
  nextPCard(s, isTeam) !== null &&
  !(s.secondsLeft === 0 && s.leftScore === s.rightScore);

/** Puts back a clock that ran past the minute (e.g. a throttled background tab) to exactly one minute. */
export const clampToNonCombativity = (s: MatchState): MatchState => ({
  ...s,
  secondsLeft: Math.max(s.secondsLeft, s.idleFromSeconds - NON_COMBATIVITY_SECONDS),
});

/** P-red to both sides: a penalty touch for each. The period continues. */
export const issuePRed = (s: MatchState): MatchState =>
  restartMinute({ ...addScore(addScore(s, 'left', 1), 'right', 1), pRed: true });

/** The side with the lower score gets the P-black; null on a tie, where the lower initial seed gets it. */
export const pBlackLoser = (s: MatchState): Side | null => {
  if (s.leftScore === s.rightScore) return null;
  return s.leftScore < s.rightScore ? 'left' : 'right';
};

/** P-black on a tie: the side with the higher initial seed wins. */
export const pBlackLoserBySeed = (higherSeed: Side): Side => opposite(higherSeed);

export const issuePBlack = (s: MatchState, loser: Side): MatchState => restartMinute({ ...s, pBlack: loser });

/** Takes back the most recent P-card, for a card given by mistake. */
export const revokeLastPCard = (s: MatchState): MatchState => {
  if (s.pBlack) return { ...s, pBlack: null };
  if (s.pRed) return { ...addScore(addScore(s, 'left', -1), 'right', -1), pRed: false };
  return s;
};

/** Counts down one second, stopping at zero. */
export const tick = (s: MatchState): MatchState =>
  s.secondsLeft > 0 ? { ...s, secondsLeft: s.secondsLeft - 1 } : s;

/** Setting the clock starts a period, so the non-combativity minute starts again. */
export const setSecondsLeft = (s: MatchState, seconds: number): MatchState =>
  restartMinute({ ...s, secondsLeft: Math.max(0, Math.trunc(seconds)) });

export const clampMatchNumber = (n: number): number =>
  Math.min(MAX_MATCH_NUMBER, Math.max(MIN_MATCH_NUMBER, Math.trunc(n)));

/** A new relay starts the non-combativity minute again; P-cards stay for the whole team match. */
export const setMatchNumber = (s: MatchState, n: number): MatchState =>
  restartMinute({ ...s, matchNumber: clampMatchNumber(n) });

export const increaseMatchNumber = (s: MatchState): MatchState => setMatchNumber(s, s.matchNumber + 1);

export const decreaseMatchNumber = (s: MatchState): MatchState => setMatchNumber(s, s.matchNumber - 1);
