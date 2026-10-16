import { useState } from 'react';
import { setMatchNumber } from '../app/actions';
import { MATCH_UP_PATTERNS } from '../domain/matchups';
import { MAX_MATCH_NUMBER, MIN_MATCH_NUMBER } from '../domain/scoring';
import { t } from '../i18n';
import { useMatch } from '../state/matchStore';
import { showToast } from '../state/toastStore';
import { Modal } from './Modal';

const numbers = Array.from(
  { length: MAX_MATCH_NUMBER - MIN_MATCH_NUMBER + 1 },
  (_, i) => i + MIN_MATCH_NUMBER,
);

export const MatchNumberDialog = ({ onClose }: { onClose: () => void }) => {
  const [value, setValue] = useState(() => useMatch.getState().matchNumber);

  const apply = () => {
    setMatchNumber(value);
    showToast(t.matchNumberChangedMessage);
    onClose();
  };

  return (
    <Modal
      title={t.matchNumberSettingTitle}
      onClose={onClose}
      actions={
        <>
          <button type="button" className="btn text" onClick={onClose}>
            {t.close}
          </button>
          <button type="button" className="btn primary" onClick={apply}>
            {t.change}
          </button>
        </>
      }
    >
      <div className="field-row">
        <label>
          <select value={value} onChange={(e) => setValue(Number(e.target.value))}>
            {numbers.map((n) => (
              <option key={n} value={n}>
                {n} — {MATCH_UP_PATTERNS[n]}
              </option>
            ))}
          </select>
        </label>
      </div>
    </Modal>
  );
};
