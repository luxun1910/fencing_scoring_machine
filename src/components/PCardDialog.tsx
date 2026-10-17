import { dismissPCard, issuePBlack, issuePRed, nextPCard, revokeLastPCard } from '../app/actions';
import { pBlackLoser, pBlackLoserBySeed, type Side } from '../domain/scoring';
import { t } from '../i18n';
import { useMatch } from '../state/matchStore';
import { Modal } from './Modal';

const sideName = (side: Side) => (side === 'left' ? t.left : t.right);

/** Proposes the next P-card for unwillingness to fight (FIE t.124), or takes back the last one. */
export const PCardDialog = ({ onClose }: { onClose: () => void }) => {
  // Subscribed so the dialog follows the score it is about.
  const match = useMatch();
  const card = nextPCard();
  const loser = pBlackLoser(match);
  const canRevoke = match.pRed || match.pBlack !== null;

  const close = () => {
    dismissPCard();
    onClose();
  };
  const done = (award: () => void) => () => {
    award();
    onClose();
  };

  let message = t.pCardUnavailableMessage;
  if (card === 'red') message = t.pRedMessage;
  else if (card === 'black' && loser)
    message = t.pBlackMessage
      .replace('{loser}', sideName(loser))
      .replace('{winner}', sideName(loser === 'left' ? 'right' : 'left'));
  else if (card === 'black') message = t.pBlackTieMessage;

  return (
    <Modal
      title={t.pCardDialogTitle}
      onClose={close}
      actions={
        <>
          <button type="button" className="btn text" onClick={close}>
            {t.close}
          </button>
          {card === 'red' && (
            <button type="button" className="btn primary p-red" onClick={done(issuePRed)}>
              {t.pRedButtonText}
            </button>
          )}
          {card === 'black' && loser && (
            <button type="button" className="btn primary p-black" onClick={done(() => issuePBlack(loser))}>
              {t.pBlackButtonText}
            </button>
          )}
          {card === 'black' &&
            !loser &&
            (['left', 'right'] as const).map((higherSeed) => (
              <button
                key={higherSeed}
                type="button"
                className="btn primary"
                onClick={done(() => issuePBlack(pBlackLoserBySeed(higherSeed)))}
              >
                {sideName(higherSeed)}
              </button>
            ))}
        </>
      }
    >
      <p>{message}</p>
      {canRevoke && (
        <button type="button" className="btn text" onClick={done(revokeLastPCard)}>
          {t.revokePCardButtonText}
        </button>
      )}
    </Modal>
  );
};
