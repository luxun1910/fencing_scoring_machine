import { useState } from 'react';
import { setSecondsLeft } from '../app/actions';
import { splitMinutesSeconds } from '../domain/time';
import { t } from '../i18n';
import { useMatch } from '../state/matchStore';
import { showToast } from '../state/toastStore';
import { Modal } from './Modal';

const range = (n: number) => Array.from({ length: n }, (_, i) => i);

export const TimeDialog = ({ onClose }: { onClose: () => void }) => {
  const initial = splitMinutesSeconds(useMatch.getState().secondsLeft);
  const [minutes, setMinutes] = useState(initial.minutes);
  const [seconds, setSeconds] = useState(initial.seconds);

  const apply = () => {
    setSecondsLeft(minutes * 60 + seconds);
    showToast(t.timerChangedMessage);
    onClose();
  };

  return (
    <Modal
      title={t.timerSettingTitle}
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
          <select value={minutes} onChange={(e) => setMinutes(Number(e.target.value))}>
            {range(4).map((m) => (
              <option key={m} value={m}>
                {m}
              </option>
            ))}
          </select>
          <span>{t.minutes}</span>
        </label>
        <label>
          <select value={seconds} onChange={(e) => setSeconds(Number(e.target.value))}>
            {range(60).map((s) => (
              <option key={s} value={s}>
                {String(s).padStart(2, '0')}
              </option>
            ))}
          </select>
          <span>{t.seconds}</span>
        </label>
      </div>
    </Modal>
  );
};
