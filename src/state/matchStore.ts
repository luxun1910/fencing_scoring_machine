import { create } from 'zustand';
import { initialMatchState, type MatchState } from '../domain/scoring';
import { remainingSeconds } from '../domain/time';

export interface RecordedVideo {
  blob: Blob;
  /** Object URL for playback. Revoked when a newer video replaces it. */
  url: string;
  fileName: string;
}

/** Where a running clock was started; null while stopped. */
interface TimerAnchor {
  startedAt: number;
  secondsAtStart: number;
}

interface MatchStore extends MatchState {
  timer: TimerAnchor | null;
  /** Only the most recent recording is kept, like the original app deleting older files. */
  latestVideo: RecordedVideo | null;

  /** Applies a pure domain transition. */
  apply: (transition: (s: MatchState) => MatchState) => void;
  startTimer: (now: number) => void;
  stopTimer: (now: number) => void;
  /** Recomputes secondsLeft of a running clock. */
  syncTimer: (now: number) => void;
  setLatestVideo: (video: RecordedVideo) => void;
}

const secondsAt = (timer: TimerAnchor, now: number) =>
  remainingSeconds(timer.secondsAtStart, now - timer.startedAt);

export const useMatch = create<MatchStore>()((set, get) => ({
  ...initialMatchState,
  timer: null,
  latestVideo: null,

  apply: (transition) => {
    const { leftScore, rightScore, secondsLeft, matchNumber } = get();
    set(transition({ leftScore, rightScore, secondsLeft, matchNumber }));
  },

  startTimer: (now) => {
    if (get().timer) return;
    set({ timer: { startedAt: now, secondsAtStart: get().secondsLeft } });
  },

  stopTimer: (now) => {
    const { timer } = get();
    if (!timer) return;
    set({ secondsLeft: secondsAt(timer, now), timer: null });
  },

  syncTimer: (now) => {
    const { timer, secondsLeft } = get();
    if (!timer) return;
    const next = secondsAt(timer, now);
    if (next !== secondsLeft) set({ secondsLeft: next });
  },

  setLatestVideo: (video) => {
    const previous = get().latestVideo;
    if (previous) URL.revokeObjectURL(previous.url);
    set({ latestVideo: video });
  },
}));

export const selectIsTimerRunning = (s: MatchStore) => s.timer !== null;
