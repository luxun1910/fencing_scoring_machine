import { formatRemaining, msUntilNextTick, remainingSeconds, splitMinutesSeconds } from '../src/domain/time';

describe('time', () => {
  it('formats MM:SS', () => {
    expect(formatRemaining(0)).toBe('00:00');
    expect(formatRemaining(59)).toBe('00:59');
    expect(formatRemaining(225)).toBe('03:45');
  });

  it('splits minutes and seconds', () => {
    expect(splitMinutesSeconds(185)).toEqual({ minutes: 3, seconds: 5 });
  });

  it('derives whole seconds from elapsed time', () => {
    expect(remainingSeconds(180, 0)).toBe(180);
    expect(remainingSeconds(180, 999)).toBe(180);
    expect(remainingSeconds(180, 1000)).toBe(179);
    expect(remainingSeconds(180, 61_500)).toBe(119);
  });

  it('never goes below zero', () => {
    expect(remainingSeconds(3, 10_000)).toBe(0);
  });

  it('computes the delay to the next tick', () => {
    expect(msUntilNextTick(0)).toBe(1000);
    expect(msUntilNextTick(250)).toBe(750);
    expect(msUntilNextTick(1999)).toBe(1);
  });
});
