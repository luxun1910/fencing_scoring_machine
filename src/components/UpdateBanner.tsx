import { t } from '../i18n';
import { useUpdate } from '../state/updateStore';

/** Offers a downloaded new version; applying it reloads the page, so the user picks the moment. */
export const UpdateBanner = () => {
  const needRefresh = useUpdate((s) => s.needRefresh);
  const applyUpdate = useUpdate((s) => s.applyUpdate);
  if (!needRefresh) return null;

  return (
    <aside className="install-banner" aria-label={t.updateBannerText}>
      <span>{t.updateBannerText}</span>
      <button type="button" className="btn" onClick={() => void applyUpdate()}>
        {t.updateButtonText}
      </button>
    </aside>
  );
};
