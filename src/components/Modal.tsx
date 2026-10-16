import { useEffect, useRef, type ReactNode } from 'react';

interface ModalProps {
  title: string;
  onClose: () => void;
  children?: ReactNode;
  actions?: ReactNode;
}

/** Native modal <dialog>, open for as long as it is mounted. Esc and backdrop clicks close it. */
export const Modal = ({ title, onClose, children, actions }: ModalProps) => {
  const ref = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    const dialog = ref.current;
    if (dialog && !dialog.open) dialog.showModal();
  }, []);

  return (
    <dialog
      ref={ref}
      className="modal"
      onClose={onClose}
      onClick={(e) => {
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <h2>{title}</h2>
      {children}
      {actions && <div className="modal-actions">{actions}</div>}
    </dialog>
  );
};
