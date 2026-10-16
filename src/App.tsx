import { Route, Switch } from 'wouter';
import { Toast } from './components/Toast';
import { useAppLifecycle } from './hooks/useAppLifecycle';
import { ScoringPage } from './pages/ScoringPage';
import { SettingsPage } from './pages/SettingsPage';
import { VideoPlayerPage } from './pages/VideoPlayerPage';

export const App = () => {
  useAppLifecycle();
  return (
    <>
      <Switch>
        <Route path="/settings" component={SettingsPage} />
        <Route path="/video" component={VideoPlayerPage} />
        <Route component={ScoringPage} />
      </Switch>
      <Toast />
    </>
  );
};
