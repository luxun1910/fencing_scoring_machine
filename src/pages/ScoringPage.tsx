import type { CSSProperties } from 'react';
import { Link } from 'wouter';
import { CameraView } from '../components/CameraView';
import { ControlPanel } from '../components/ControlPanel';
import { InstallBanner } from '../components/InstallBanner';
import { UpdateBanner } from '../components/UpdateBanner';
import { SettingsIcon } from '../components/icons';
import { IN_APP } from '../app/navigation';
import { ScoreColumn } from '../components/ScoreColumn';
import { t } from '../i18n';
import { selectIsTimerRunning, useMatch } from '../state/matchStore';
import { useSettings } from '../state/settingsStore';

export const ScoringPage = () => {
  const videoEnable = useSettings((s) => s.videoEnable);
  const previewSize = useSettings((s) => s.videoPreviewSize);
  const previewPosition = useSettings((s) => s.videoPreviewPosition);
  const running = useMatch(selectIsTimerRunning);

  return (
    <div className="scoring-screen">
      {/* Above the board rather than over it, so it never hides a score. */}
      {!running && <UpdateBanner />}
      {!running && <InstallBanner />}
      <div
        className="scoring-page"
        data-preview-position={previewPosition}
        style={{ '--preview-flex': previewSize } as CSSProperties}
      >
        {/* One preview element for both orientations; CSS moves it, so the stream never re-attaches. */}
        {videoEnable && (
          <section className="camera-pane">
            <CameraView />
          </section>
        )}
        <main className="board">
          <ScoreColumn side="left" />
          <ControlPanel />
          <ScoreColumn side="right" />
        </main>
        {!running && (
          <Link href="/settings" state={IN_APP} className="fab" aria-label={t.settingsTitle}>
            <SettingsIcon />
          </Link>
        )}
      </div>
    </div>
  );
};
