import { MATCH_UP_PATTERNS } from '../src/domain/matchups';
import {
  decreaseMatchNumber,
  doubleHit,
  increaseMatchNumber,
  initialMatchState,
  resetBout,
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
