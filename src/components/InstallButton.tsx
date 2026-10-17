import { useState } from 'react';
import { t } from '../i18n';
import { promptInstall, selectInstallMode, useInstall } from '../state/installStore';
import { Modal } from './Modal';

/** Share sheet steps for iOS, which has no install API. */
const IosInstallDialog = ({ onClose }: { onClose: () => void }) => (
  <Modal
    title={t.installIosTitle}
    onClose={onClose}
    actions={
      <button type="button" className="btn primary" onClick={onClose}>
        {t.close}
      </button>
    }
  >
    <ol className="install-steps">
      <li>{t.installIosStep1}</li>
      <li>{t.installIosStep2}</li>
      <li>{t.installIosStep3}</li>
    </ol>
  </Modal>
);

/** Installs the app (Android/desktop Chromium) or explains how to (iOS). Renders nothing otherwise. */
export const InstallButton = ({ className = 'btn primary' }: { className?: string }) => {
  const mode = useInstall(selectInstallMode);
  const [showIos, setShowIos] = useState(false);

  if (mode === 'none' && !showIos) return null;
  return (
    <>
      {mode !== 'none' && (
        <button
          type="button"
          className={className}
          onClick={() => (mode === 'prompt' ? void promptInstall() : setShowIos(true))}
        >
          {mode === 'prompt' ? t.installButtonText : t.installHowToButtonText}
        </button>
      )}
      {showIos && <IosInstallDialog onClose={() => setShowIos(false)} />}
    </>
  );
};
