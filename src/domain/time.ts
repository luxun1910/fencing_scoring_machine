const pad2 = (n: number) => n.toString().padStart(2, '0');

/** Formats seconds as "MM:SS". */
export const formatRemaining = (totalSeconds: number): string =>
  `${pad2(Math.floor(totalSeconds / 60))}:${pad2(totalSeconds % 60)}`;

export const splitMinutesSeconds = (totalSeconds: number) => ({
  minutes: Math.floor(totalSeconds / 60),
  seconds: totalSeconds % 60,
});

/**
 * Seconds left on a running clock. The clock is anchored at the moment it was started, so the value
 * is derived from elapsed time rather than by counting interval callbacks (which drift and get
 * throttled in background tabs). It still moves in whole-second steps and never goes below zero.
 */
export const remainingSeconds = (secondsAtStart: number, elapsedMs: number): number =>
  Math.max(0, secondsAtStart - Math.floor(Math.max(0, elapsedMs) / 1000));

/** Milliseconds until a running clock shows the next second. */
export const msUntilNextTick = (elapsedMs: number): number => 1000 - (Math.max(0, elapsedMs) % 1000);
