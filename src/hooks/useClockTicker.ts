import { useEffect } from 'react';
import { checkNonCombativity } from '../app/actions';
import { msUntilNextTick, remainingSeconds } from '../domain/time';
import { useMatch } from '../state/matchStore';

/**
 * Drives a running clock. Rather than a 1-second interval, it wakes up right after each second
 * boundary of the clock's own start time, so the display never drifts.
 */
export const useClockTicker = () => {
  const timer = useMatch((s) => s.timer);

  useEffect(() => {
    if (!timer) return;
    let id: number | undefined;
    const step = () => {
      const now = performance.now();
      useMatch.getState().syncTimer(now);
      checkNonCombativity();
      // A halt for unwillingness to fight clears the timer, which also tears this effect down.
      if (!useMatch.getState().timer) return;
      const elapsed = now - timer.startedAt;
      if (remainingSeconds(timer.secondsAtStart, elapsed) === 0) return;
      // Small slack so the callback lands just after the boundary, not just before it.
      id = window.setTimeout(step, msUntilNextTick(elapsed) + 5);
    };
    step();
    return () => window.clearTimeout(id);
  }, [timer]);
};
