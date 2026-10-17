import { PageHeader } from '../components/PageHeader';
import { t } from '../i18n';
import { useSettings, type Settings } from '../state/settingsStore';

const PRIVACY_POLICY_URL =
  'https://luxun1910.github.io/unanimousworks_privacy_policy/fencing_scoring_machine.html';

interface ChoiceProps<K extends keyof Settings> {
  setting: K;
  legend: string;
  hint?: string;
  options: readonly { value: Settings[K]; label: string }[];
}

/** One setting rendered as a segmented radio group. */
const Choice = <K extends keyof Settings>({ setting, legend, hint, options }: ChoiceProps<K>) => {
  const value = useSettings((s) => s[setting]);
  const set = useSettings((s) => s.set);
  return (
    <fieldset className="choice">
      <legend>{legend}</legend>
      {hint && <p className="hint">{hint}</p>}
      <div className="segmented">
        {options.map((o) => (
          <label key={String(o.value)}>
            <input
              type="radio"
              name={setting}
              checked={value === o.value}
              onChange={() => set(setting, o.value)}
            />
            <span>{o.label}</span>
          </label>
        ))}
      </div>
    </fieldset>
  );
};

const onOff = [
  { value: true, label: t.enable },
  { value: false, label: t.disable },
] as const;

export const SettingsPage = () => (
  <div className="sub-page">
    <PageHeader title={t.settingsTitle} />
    <div className="settings-list">
      <Choice setting="videoEnable" legend={t.videoEnableOptionText} options={onOff} />
      <Choice
        setting="videoAutoSave"
        legend={t.videoAutosaveOptionText}
        hint={t.videoAutosaveOptionSubText}
        options={onOff}
      />
      <Choice
        setting="videoPreviewSize"
        legend={t.videoPreviewSizeOptionText}
        options={[
          { value: 1, label: 'S' },
          { value: 2, label: 'M' },
          { value: 3, label: 'L' },
        ]}
      />
      <Choice
        setting="videoPreviewPosition"
        legend={t.videoPositionOptionText}
        options={[
          { value: 'left', label: t.left },
          { value: 'right', label: t.right },
        ]}
      />
      <Choice setting="doubleButtonEnable" legend={t.doubleButtonOptionText} options={onOff} />
      <Choice setting="matchNumberCountEnable" legend={t.matchNumberCountOptionText} options={onOff} />
      <Choice setting="pCardEnable" legend={t.pCardOptionText} hint={t.pCardOptionSubText} options={onOff} />
      <a className="link" href={PRIVACY_POLICY_URL} target="_blank" rel="noreferrer">
        {t.privacyPolicy}
      </a>
    </div>
  </div>
);
