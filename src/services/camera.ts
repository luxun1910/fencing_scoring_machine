import { create } from 'zustand';
import type { RecordedVideo } from '../state/matchStore';

export type CameraStatus = 'off' | 'starting' | 'ready' | 'error';

export interface ZoomRange {
  min: number;
  max: number;
  step: number;
}

interface CameraState {
  status: CameraStatus;
  stream: MediaStream | null;
  isRecording: boolean;
  /** Null when the device or browser does not support zoom; the slider is hidden then. */
  zoom: ZoomRange | null;
  zoomValue: number;
}

export const useCamera = create<CameraState>()(() => ({
  status: 'off',
  stream: null,
  isRecording: false,
  zoom: null,
  zoomValue: 1,
}));

// `zoom` is a non-standard-yet constraint (Chrome on Android supports it).
type ZoomCapabilities = MediaTrackCapabilities & { zoom?: { min: number; max: number; step?: number } };
type ZoomSettings = MediaTrackSettings & { zoom?: number };

const MIME_CANDIDATES = [
  'video/mp4;codecs=avc1,mp4a',
  'video/mp4',
  'video/webm;codecs=vp9,opus',
  'video/webm',
];

const pickMimeType = (): string | undefined =>
  typeof MediaRecorder === 'undefined'
    ? undefined
    : MIME_CANDIDATES.find((type) => MediaRecorder.isTypeSupported(type));

const VIDEO_CONSTRAINTS: MediaTrackConstraints = {
  facingMode: { ideal: 'environment' },
  width: { ideal: 1280 },
  height: { ideal: 720 },
};

const openStream = async (): Promise<MediaStream> => {
  try {
    return await navigator.mediaDevices.getUserMedia({ video: VIDEO_CONSTRAINTS, audio: true });
  } catch (e) {
    // Devices without a microphone still get video.
    if (e instanceof DOMException && e.name === 'NotFoundError') {
      return navigator.mediaDevices.getUserMedia({ video: VIDEO_CONSTRAINTS, audio: false });
    }
    throw e;
  }
};

const readZoom = (track: MediaStreamTrack | undefined): Pick<CameraState, 'zoom' | 'zoomValue'> => {
  const caps = track?.getCapabilities?.() as ZoomCapabilities | undefined;
  if (!caps?.zoom || caps.zoom.max <= caps.zoom.min) return { zoom: null, zoomValue: 1 };
  const { min, max, step = 0.1 } = caps.zoom;
  const current = (track?.getSettings() as ZoomSettings | undefined)?.zoom ?? min;
  return { zoom: { min, max, step }, zoomValue: current };
};

const stopTracks = (stream: MediaStream | null) => stream?.getTracks().forEach((t) => t.stop());

/** Incremented on every acquire/release so a slow getUserMedia can't revive a released camera. */
let generation = 0;
let recorder: MediaRecorder | null = null;
let chunks: Blob[] = [];

export const acquireCamera = async (): Promise<void> => {
  const gen = ++generation;
  if (useCamera.getState().stream) return;
  if (!navigator.mediaDevices?.getUserMedia) {
    useCamera.setState({ status: 'error' });
    return;
  }
  useCamera.setState({ status: 'starting' });
  let stream: MediaStream;
  try {
    stream = await openStream();
  } catch (e) {
    console.error('Camera unavailable', e);
    if (gen === generation) useCamera.setState({ status: 'error' });
    return;
  }
  if (gen !== generation) {
    stopTracks(stream);
    return;
  }
  useCamera.setState({ status: 'ready', stream, ...readZoom(stream.getVideoTracks()[0]) });
};

/** Stops any recording in progress and turns the camera off. Resolves with the unfinished recording, if any. */
export const releaseCamera = async (): Promise<RecordedVideo | null> => {
  generation++;
  // Detach synchronously so a re-acquire right after this starts clean; the recorder keeps using the
  // old tracks until it has flushed, and only then are they stopped.
  const { stream } = useCamera.getState();
  useCamera.setState({ status: 'off', stream: null, zoom: null, zoomValue: 1 });
  const video = await stopRecording();
  stopTracks(stream);
  return video;
};

export const startRecording = (): void => {
  const { stream } = useCamera.getState();
  if (!stream || recorder) return;
  try {
    const mimeType = pickMimeType();
    recorder = new MediaRecorder(stream, mimeType ? { mimeType } : undefined);
  } catch (e) {
    console.error('Video recording failed', e);
    recorder = null;
    return;
  }
  chunks = [];
  recorder.ondataavailable = (e) => {
    if (e.data.size > 0) chunks.push(e.data);
  };
  // A timeslice keeps memory chunked and avoids losing everything if the tab is killed mid-bout.
  recorder.start(1000);
  useCamera.setState({ isRecording: true });
};

const timestamp = (d: Date) =>
  [d.getFullYear(), d.getMonth() + 1, d.getDate()].map((n) => String(n).padStart(2, '0')).join('') +
  '_' +
  [d.getHours(), d.getMinutes(), d.getSeconds()].map((n) => String(n).padStart(2, '0')).join('');

export const stopRecording = (): Promise<RecordedVideo | null> => {
  const active = recorder;
  recorder = null;
  if (!active || active.state === 'inactive') {
    useCamera.setState({ isRecording: false });
    return Promise.resolve(null);
  }
  return new Promise((resolve) => {
    active.onstop = () => {
      const type = active.mimeType || 'video/webm';
      const blob = new Blob(chunks, { type });
      chunks = [];
      useCamera.setState({ isRecording: false });
      if (blob.size === 0) return resolve(null);
      const ext = type.startsWith('video/mp4') ? 'mp4' : 'webm';
      resolve({ blob, url: URL.createObjectURL(blob), fileName: `fencing_${timestamp(new Date())}.${ext}` });
    };
    active.stop();
  });
};

export const setZoom = (value: number): void => {
  const { stream, zoom } = useCamera.getState();
  const track = stream?.getVideoTracks()[0];
  if (!track || !zoom) return;
  const clamped = Math.min(zoom.max, Math.max(zoom.min, value));
  useCamera.setState({ zoomValue: clamped });
  track
    .applyConstraints({ advanced: [{ zoom: clamped } as MediaTrackConstraintSet] })
    .catch((e: unknown) => console.warn('Zoom failed', e));
};
