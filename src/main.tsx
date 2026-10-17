import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { App } from './App';
import { locale } from './i18n';
import { listenForInstall } from './state/installStore';
import './styles.css';

document.documentElement.lang = locale;
listenForInstall();

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
