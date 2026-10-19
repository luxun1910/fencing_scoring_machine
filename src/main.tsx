import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { App } from './App';
import { listenForInstall } from './state/installStore';
import { registerServiceWorker } from './services/serviceWorker';
import './styles.css';

listenForInstall();
registerServiceWorker();

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
