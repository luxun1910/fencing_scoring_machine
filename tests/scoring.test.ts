import { MATCH_UP_PATTERNS } from '../src/domain/matchups';
import {
  clampToNonCombativity,
  decreaseMatchNumber,
  doubleHit,
  idleSeconds,
  increaseMatchNumber,
  initialMatchState,
  isNonCombativity,
  issuePBlack,
  issuePRed,
  nextPCard,
  pBlackLoser,
  pBlackLoserBySeed,
  resetBout,
  revokeLastPCard,
  scoreDown,
  scoreUp,
  setMatchNumber,
  setSecondsLeft,
  tick,
  type MatchState,
} from '../src/domain/scoring';
import { formatRemaining } from '../src/domain/time';

const remaining = (s: MatchState) => formatRemaining(s.secondsLeft);

describe('scoring', () => {
  const s = initialMatchState;

  it('starts at 03:00 with 0-0', () => {
    expect(remaining(s)).toBe('03:00');
    expect([s.leftScore, s.rightScore]).toEqual([0, 0]);
  });

  it('shows 02:59 after one tick', () => {
    expect(remaining(tick(s))).toBe('02:59');
  });

  it('does not go below 00:00', () => {
    const zero = setSecondsLeft(s, 0);
    expect(remaining(zero)).toBe('00:00');
    expect(remaining(tick(zero))).toBe('00:00');
  });

  it('increments and decrements each side, allowing negative scores', () => {
    expect(scoreUp(s, 'left').leftScore).toBe(1);
    expect(scoreUp(s, 'right').rightScore).toBe(1);
    expect(scoreDown(s, 'left').leftScore).toBe(-1);
    expect(scoreDown(s, 'right').rightScore).toBe(-1);
  });

  it('adds a point to both sides on a double hit', () => {
    const d = doubleHit(s);
    expect([d.leftScore, d.rightScore]).toEqual([1, 1]);
  });

  it('resets scores and clock but keeps the match number', () => {
    const played = setMatchNumber(tick(scoreUp(scoreUp(s, 'left'), 'right')), 4);
    const r = resetBout(played);
    expect([r.leftScore, r.rightScore]).toEqual([0, 0]);
    expect(remaining(r)).toBe('03:00');
    expect(r.matchNumber).toBe(4);
  });

  it('accumulates repeated changes', () => {
    expect(scoreDown(scoreUp(scoreUp(s, 'left'), 'left'), 'left').leftScore).toBe(1);
    expect(scoreDown(scoreUp(scoreUp(scoreUp(s, 'right'), 'right'), 'right'), 'right').rightScore).toBe(2);
  });

  it('sets the remaining time directly', () => {
    expect(remaining(setSecondsLeft(s, 120))).toBe('02:00');
    expect(remaining(setSecondsLeft(s, 30))).toBe('00:30');
  });

  it('does not mutate its input', () => {
    const before = { ...s };
    scoreUp(s, 'left');
    tick(s);
    resetBout(s);
    expect(s).toEqual(before);
  });
});

describe('match number', () => {
  it('cannot go below 1', () => {
    const s = setMatchNumber(initialMatchState, 1);
    expect(decreaseMatchNumber(s).matchNumber).toBe(1);
    expect(setMatchNumber(s, 0).matchNumber).toBe(1);
  });

  it('cannot go above 9', () => {
    const s = setMatchNumber(initialMatchState, 9);
    expect(increaseMatchNumber(s).matchNumber).toBe(9);
    expect(setMatchNumber(s, 10).matchNumber).toBe(9);
  });

  it('has a match-up pattern for every valid number', () => {
    for (let n = 1; n <= 9; n++) expect(MATCH_UP_PATTERNS[n]).toMatch(/^\d VS \d$/);
    expect(MATCH_UP_PATTERNS[1]).toBe('3 VS 6');
    expect(MATCH_UP_PATTERNS[9]).toBe('3 VS 5');
  });
});

describe('unwillingness to fight (t.124)', () => {
  /** n seconds of fencing without a touch. */
  const fence = (s: MatchState, n: number) => {
    for (let i = 0; i < n; i++) s = tick(s);
    return s;
  };
  const at = (left: number, right: number): MatchState => ({
    ...initialMatchState,
    leftScore: left,
    rightScore: right,
  });

  it('fires after one minute of fencing without a touch', () => {
    expect(isNonCombativity(fence(initialMatchState, 59), false)).toBe(false);
    const s = fence(initialMatchState, 60);
    expect(idleSeconds(s)).toBe(60);
    expect(isNonCombativity(s, false)).toBe(true);
  });

  it.each([
    ['a touch', (s: MatchState) => scoreUp(s, 'left')],
    ['a hit annulled', (s: MatchState) => scoreDown(s, 'right')],
    ['a double hit', doubleHit],
    ['a new period', (s: MatchState) => setSecondsLeft(s, 180)],
    ['a new relay', increaseMatchNumber],
  ] as const)('restarts the minute after %s', (_, transition) => {
    const s = fence(transition(fence(initialMatchState, 50)), 50);
    expect(idleSeconds(s)).toBe(50);
    expect(isNonCombativity(s, false)).toBe(false);
  });

  it('awards P-red first: a touch for each side, and the minute restarts', () => {
    const s = fence(at(3, 5), 60);
    expect(nextPCard(s, false)).toBe('red');
    const red = issuePRed(s);
    expect([red.leftScore, red.rightScore]).toEqual([4, 6]);
    expect(red.pRed).toBe(true);
    expect(idleSeconds(red)).toBe(0);
    expect(nextPCard(red, false)).toBe('black');
  });

  it('gives the P-black to the lower score, or to the lower seed on a tie', () => {
    expect(pBlackLoser(at(4, 6))).toBe('left');
    expect(pBlackLoser(at(7, 6))).toBe('right');
    expect(pBlackLoser(at(5, 5))).toBeNull();
    expect(pBlackLoserBySeed('left')).toBe('right');

    const black = issuePBlack({ ...at(4, 6), pRed: true }, 'left');
    expect(black.pBlack).toBe('left');
    expect([black.leftScore, black.rightScore]).toEqual([4, 6]);
    expect(nextPCard(black, false)).toBeNull();
  });

  it('awards no P-card at 14-14 (individual) or 44-44 (team)', () => {
    expect(nextPCard(fence(at(14, 14), 60), false)).toBeNull();
    expect(isNonCombativity(fence(at(14, 14), 60), false)).toBe(false);
    expect(nextPCard(at(14, 14), true)).toBe('red');
    expect(nextPCard(at(44, 44), true)).toBeNull();
  });

  it('does not apply to a tie at the end of regulation time', () => {
    const end = fence(setSecondsLeft(at(5, 5), 60), 60);
    expect(end.secondsLeft).toBe(0);
    expect(isNonCombativity(end, false)).toBe(false);
    expect(isNonCombativity({ ...end, leftScore: 6 }, false)).toBe(true);
  });

  it('keeps P-cards through relays and clears them on reset', () => {
    const red = issuePRed(initialMatchState);
    expect(increaseMatchNumber(red).pRed).toBe(true);
    const cleared = resetBout(issuePBlack(red, 'left'));
    expect([cleared.pRed, cleared.pBlack]).toEqual([false, null]);
  });

  it('revokes the last P-card', () => {
    const red = issuePRed(at(3, 3));
    const black = issuePBlack(red, 'right');
    expect(revokeLastPCard(black)).toMatchObject({ pRed: true, pBlack: null, leftScore: 4 });
    expect(revokeLastPCard(red)).toMatchObject({ pRed: false, leftScore: 3, rightScore: 3 });
  });

  it('puts a clock that ran past the minute back to exactly one minute', () => {
    expect(clampToNonCombativity(fence(initialMatchState, 63)).secondsLeft).toBe(120);
    expect(clampToNonCombativity(fence(initialMatchState, 30)).secondsLeft).toBe(150);
  });
});
