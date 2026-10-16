import { useEffect } from 'react';
import { shutDownCamera, stopTimer } from '../app/actions';
import { acquireCamera } from '../services/camera';
import { selectIsTimerRunning, useMatch } from '../state/matchStore';
import { useSettings } from '../state/settingsStore';
import { useClockTicker } from './useClockTicker';
import { usePageVisible } from './usePageVisible';
import { useWakeLock } from './useWakeLock';

/** App-wide side effects: the clock, the camera's lifetime and the screen wake lock. */
export const useAppLifecycle = () => {
  const visible = usePageVisible();
  const videoEnable = useSettings((s) => s.videoEnable);
  const running = useMatch(selectIsTimerRunning);

  useClockTicker();
  useWakeLock(running);

  // Leaving the app pauses the bout, as the mobile app did on pause/inactive.
  useEffect(() => {
    if (!visible) stopTimer();
  }, [visible]);

  // The camera stays open across pages while visible, and is released in the background.
  useEffect(() => {
    if (!visible || !videoEnable) return;
    void acquireCamera();
    return () => void shutDownCamera();
  }, [visible, videoEnable]);
};
