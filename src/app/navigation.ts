/** History state marking pages opened from within the app, so "back" can pop instead of push. */
export const IN_APP = { inApp: true } as const;

export const openedInApp = () => (history.state as typeof IN_APP | null)?.inApp === true;
