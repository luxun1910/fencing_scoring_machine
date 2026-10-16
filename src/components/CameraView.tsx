import { useEffect, useRef, useState } from 'react';
import { useLocation } from 'wouter';
import { t } from '../i18n';
import { setZoom, useCamera } from '../services/camera';
import { useMatch } from '../state/matchStore';
import { Modal } from './Modal';
import { IN_APP } from '../app/navigation';

const ZoomSlider = () => {
  const zoom = useCamera((s) => s.zoom);
  const value = useCamera((s) => s.zoomValue);
  if (!zoom) return null;
  return (
    <input
      type="range"
      className="zoom-slider"
      aria-label="zoom"
      min={zoom.min}
      max={zoom.max}
      step={zoom.step}
      value={value}
      onChange={(e) => setZoom(Number(e.target.value))}
    />
  );
};

/** Live camera preview. Tapping it while not recording opens the latest recording. */
export const CameraView = () => {
  const stream = useCamera((s) => s.stream);
  const status = useCamera((s) => s.status);
  const isRecording = useCamera((s) => s.isRecording);
  const hasVideo = useMatch((s) => s.latestVideo !== null);
  const [, navigate] = useLocation();
  const [permissionDismissed, setPermissionDismissed] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    if (videoRef.current) videoRef.current.srcObject = stream;
  }, [stream]);

  const openPlayer = () => {
    if (!isRecording && hasVideo) navigate('/video', { state: IN_APP });
  };

  return (
    <div className="camera-view">
      <div
        className="camera-frame"
        role="button"
        tabIndex={0}
        aria-label={t.videoPageTitle}
        aria-disabled={isRecording || !hasVideo}
        onClick={openPlayer}
        onKeyDown={(e) => {
          if (e.key === 'Enter' || e.key === ' ') openPlayer();
        }}
      >
        <video ref={videoRef} autoPlay muted playsInline />
        {status === 'starting' && <div className="spinner" aria-hidden="true" />}
        {isRecording && <span className="rec-badge">REC</span>}
        {!isRecording && hasVideo && <span className="replay-badge">▶</span>}
      </div>
      <ZoomSlider />
      {status === 'error' && !permissionDismissed && (
        <Modal
          title={t.offerPermissionDialogTitle}
          onClose={() => setPermissionDismissed(true)}
          actions={
            <button type="button" className="btn text" onClick={() => setPermissionDismissed(true)}>
              {t.close}
            </button>
          }
        >
          <p>{t.offerPermissionText}</p>
        </Modal>
      )}
    </div>
  );
};
