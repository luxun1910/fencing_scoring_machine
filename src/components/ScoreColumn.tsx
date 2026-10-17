import { scoreDown, scoreUp } from '../app/actions';
import type { Side } from '../domain/scoring';
import { useMatch } from '../state/matchStore';

export const ScoreColumn = ({ side }: { side: Side }) => {
  const score = useMatch((s) => (side === 'left' ? s.leftScore : s.rightScore));
  const pRed = useMatch((s) => s.pRed);
  const pBlack = useMatch((s) => s.pBlack === side);

  return (
    <div className="score-column" data-side={side}>
      <output className="score fit" aria-label={`${side} score`}>
        <span>{score}</span>
        {(pRed || pBlack) && (
          <span className="p-badges">
            {pRed && <span className="p-badge" data-card="red" aria-label={`${side} P-red`} />}
            {pBlack && <span className="p-badge" data-card="black" aria-label={`${side} P-black`} />}
          </span>
        )}
      </output>
      <button
        type="button"
        className="btn fit score-up"
        onClick={() => scoreUp(side)}
        aria-label={`${side} +1`}
      >
        <span>+</span>
      </button>
      <button
        type="button"
        className="btn fit score-down"
        onClick={() => scoreDown(side)}
        aria-label={`${side} -1`}
      >
        <span>−</span>
      </button>
    </div>
  );
};
