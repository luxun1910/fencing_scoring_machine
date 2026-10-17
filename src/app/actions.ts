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

/** The match counter shows team relays, so it doubles as the team-event switch (44-44 instead of 14-14). */
const isTeam = () => useSettings.getState().matchNumberCountEnable;

export const nextPCard = () => domain.nextPCard(useMatch.getState(), isTeam());

/** Called on every clock tick: one minute without a touch halts the bout and asks for a P-card. */
export const checkNonCombativity = () => {
  if (!useSettings.getState().pCardEnable) return;
  if (!domain.isNonCombativity(useMatch.getState(), isTeam())) return;
  halt(domain.clampToNonCombativity);
  useMatch.getState().setPCardPrompt(true);
};

const closePCard = (transition: (s: domain.MatchState) => domain.MatchState) => {
  halt(transition);
  useMatch.getState().setPCardPrompt(false);
};

export const issuePRed = () => closePCard(domain.issuePRed);
export const issuePBlack = (loser: domain.Side) => closePCard((s) => domain.issuePBlack(s, loser));
export const revokeLastPCard = () => closePCard(domain.revokeLastPCard);

/** Closed without a card: the minute starts again so it does not fire again straight away. */
export const dismissPCard = () => {
  const match = useMatch.getState();
  if (match.pCardPrompt) match.apply(domain.restartMinute);
  match.setPCardPrompt(false);
};

export const increaseMatchNumber = () => useMatch.getState().apply(domain.increaseMatchNumber);
export const decreaseMatchNumber = () => useMatch.getState().apply(domain.decreaseMatchNumber);
export const setMatchNumber = (n: number) => useMatch.getState().apply((s) => domain.setMatchNumber(s, n));
export const setSecondsLeft = (seconds: number) =>
  useMatch.getState().apply((s) => domain.setSecondsLeft(s, seconds));

/** Page hidden or video turned off: keep whatever was being recorded, then free the camera. */
export const shutDownCamera = async () => keepRecording(await releaseCamera());
