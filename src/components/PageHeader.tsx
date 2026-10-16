import type { ReactNode } from 'react';
import { useLocation } from 'wouter';
import { openedInApp } from '../app/navigation';
import { t } from '../i18n';
import { BackIcon } from './icons';

export const PageHeader = ({ title, actions }: { title: string; actions?: ReactNode }) => {
  const [, navigate] = useLocation();
  const back = () => {
    if (openedInApp()) history.back();
    else navigate('/', { replace: true });
  };

  return (
    <header className="page-header">
      <button type="button" className="icon-btn" aria-label={t.back} onClick={back}>
        <BackIcon />
      </button>
      <h1>{title}</h1>
      {actions}
    </header>
  );
};
