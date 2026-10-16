import { useState } from 'react';
import { Redirect } from 'wouter';
import { SaveIcon } from '../components/icons';
import { PageHeader } from '../components/PageHeader';
import { t } from '../i18n';
import { saveVideo } from '../services/videoSaver';
import { useMatch } from '../state/matchStore';
import { showToast } from '../state/toastStore';

export const VideoPlayerPage = () => {
  const video = useMatch((s) => s.latestVideo);
  const [saving, setSaving] = useState(false);

  if (!video) return <Redirect to="/" replace />;

  const save = async () => {
    setSaving(true);
    try {
      if ((await saveVideo(video)) !== 'cancelled') showToast(t.videoSaveSuccessMessage);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="sub-page">
      <PageHeader
        title={t.videoPageTitle}
        actions={
          <button type="button" className="icon-btn" aria-label={t.save} disabled={saving} onClick={save}>
            <SaveIcon />
          </button>
        }
      />
      <div className="player">
        <video key={video.url} src={video.url} controls loop playsInline />
      </div>
    </div>
  );
};
