/**
 * User intents, coordinating the match clock, the camera and settings
 * (the role of FencingScoringMachineController in the Flutter app).
 */
import * as domain from '../domain/scoring';
import { releaseCamera, startRecording, stopRecording, useCamera } from '../services/camera';
import { downloadVideo } from '../services/videoSaver';
import { useMatch, type RecordedVideo } from '../state/matchStore';
import { useSettings } from '../state/settingsStore';

const now = () => performance.now();

const keepRecording = (video: RecordedVideo | null) => {
  if (!video) return;
  useMatch.getState().setLatestVideo(video);
  if (useSettings.getState().videoAutoSave) downloadVideo(video);
};

const finishRecording = async () => keepRecording(await stopRecording());

export const stopTimer = () => useMatch.getState().stopTimer(now());

/** Start/Stop: toggles the clock and, when video is enabled, toggles recording with it. */
export const pushTimer = () => {
  const match = useMatch.getState();
  if (match.timer) stopTimer();
  else match.startTimer(now());

  if (!useSettings.getState().videoEnable) return;
  const camera = useCamera.getState();
  if (camera.status !== 'ready') {
    console.error('Camera is not initialized.');
    return;
  }
  if (camera.isRecording) void finishRecording();
  else startRecording();
};

/** A touch or a reset halts the bout: the clock and any recording stop. */
const halt = (transition: (s: domain.MatchState) => domain.MatchState) => {
  stopTimer();
  useMatch.getState().apply(transition);
  if (useCamera.getState().isRecording) void finishRecording();
};

export const scoreUp = (side: domain.Side) => halt((s) => domain.scoreUp(s, side));
export const scoreDown = (side: domain.Side) => halt((s) => domain.scoreDown(s, side));
export const doubleHit = () => halt(domain.doubleHit);
export const resetAll = () => halt(domain.resetBout);

export const increaseMatchNumber = () => useMatch.getState().apply(domain.increaseMatchNumber);
export const decreaseMatchNumber = () => useMatch.getState().apply(domain.decreaseMatchNumber);
export const setMatchNumber = (n: number) => useMatch.getState().apply((s) => domain.setMatchNumber(s, n));
export const setSecondsLeft = (seconds: number) =>
  useMatch.getState().apply((s) => domain.setSecondsLeft(s, seconds));

/** Page hidden or video turned off: keep whatever was being recorded, then free the camera. */
export const shutDownCamera = async () => keepRecording(await releaseCamera());
