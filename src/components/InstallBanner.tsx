import { t } from '../i18n';
import { dismissInstallBanner, selectInstallMode, useInstall } from '../state/installStore';
import { CloseIcon } from './icons';
import { InstallButton } from './InstallButton';

/** One-time suggestion on the scoreboard to install the app; afterwards it lives in Settings. */
export const InstallBanner = () => {
  const mode = useInstall(selectInstallMode);
  const dismissed = useInstall((s) => s.bannerDismissed);
  if (mode === 'none' || dismissed) return null;

  return (
    <aside className="install-banner" aria-label={t.installBannerText}>
      <span>{t.installBannerText}</span>
      <InstallButton />
      <button type="button" className="icon-btn" aria-label={t.dismiss} onClick={dismissInstallBanner}>
        <CloseIcon />
      </button>
    </aside>
  );
};
