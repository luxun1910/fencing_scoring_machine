import { useState } from 'react';
import { decreaseMatchNumber, doubleHit, increaseMatchNumber, pushTimer, resetAll } from '../app/actions';
import { MATCH_UP_PATTERNS } from '../domain/matchups';
import { formatRemaining } from '../domain/time';
import { t } from '../i18n';
import { selectIsTimerRunning, useMatch } from '../state/matchStore';
import { useSettings } from '../state/settingsStore';
import { MatchNumberDialog } from './MatchNumberDialog';
import { TimeDialog } from './TimeDialog';

const appNamePrefix = import.meta.env.VITE_APP_NAME_PREFIX ?? '';

export const ControlPanel = () => {
  const secondsLeft = useMatch((s) => s.secondsLeft);
  const matchNumber = useMatch((s) => s.matchNumber);
  const running = useMatch(selectIsTimerRunning);
  const doubleButtonEnable = useSettings((s) => s.doubleButtonEnable);
  const matchNumberCountEnable = useSettings((s) => s.matchNumberCountEnable);
  const [dialog, setDialog] = useState<'time' | 'match' | null>(null);

  return (
    <div className="control-panel">
      {/* Settings dialogs only open while the clock is stopped. */}
      <button
        type="button"
        className="clock fit"
        data-running={running}
        disabled={running}
        onClick={() => setDialog('time')}
      >
        <span>{formatRemaining(secondsLeft)}</span>
      </button>

      {matchNumberCountEnable && (
        <>
          <div className="matchup">{MATCH_UP_PATTERNS[matchNumber]}</div>
          <button
            type="button"
            className="match-number fit"
            disabled={running}
            onClick={() => setDialog('match')}
          >
            <span>
              {matchNumber} {t.matchNumberSuffix}
            </span>
          </button>
          <div className="match-stepper">
            <button type="button" className="btn" onClick={decreaseMatchNumber} aria-label="match number -1">
              −
            </button>
            <button type="button" className="btn" onClick={increaseMatchNumber} aria-label="match number +1">
              +
            </button>
          </div>
        </>
      )}

      {doubleButtonEnable && (
        <button type="button" className="btn double" onClick={doubleHit}>
          {t.doubleButtonText}
        </button>
      )}

      <button type="button" className="btn start-stop" data-running={running} onClick={pushTimer}>
        {t.startStopButtonText}
        {appNamePrefix}
      </button>

      <button type="button" className="btn reset" onClick={resetAll}>
        {t.resetButtonText}
      </button>

      {dialog === 'time' && <TimeDialog onClose={() => setDialog(null)} />}
      {dialog === 'match' && <MatchNumberDialog onClose={() => setDialog(null)} />}
    </div>
  );
};
