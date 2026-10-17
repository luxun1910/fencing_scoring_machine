import { useEffect } from 'react';
import { Route, Switch } from 'wouter';
import { Toast } from './components/Toast';
import { useAppLifecycle } from './hooks/useAppLifecycle';
import { currentLocale } from './i18n';
import { ScoringPage } from './pages/ScoringPage';
import { SettingsPage } from './pages/SettingsPage';
import { VideoPlayerPage } from './pages/VideoPlayerPage';
import { useSettings } from './state/settingsStore';

export const App = () => {
  useAppLifecycle();
  const language = useSettings((s) => s.language);
  useEffect(() => {
    document.documentElement.lang = currentLocale();
  }, [language]);
  return (
    <>
      {/* Remount on language change so every page re-renders with the new messages. */}
      <Switch key={language}>
        <Route path="/settings" component={SettingsPage} />
        <Route path="/video" component={VideoPlayerPage} />
        <Route component={ScoringPage} />
      </Switch>
      <Toast />
    </>
  );
};
