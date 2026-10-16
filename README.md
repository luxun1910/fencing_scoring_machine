# Fencing Scoring Machine

A fencing scoreboard that runs in the browser: scores, a 3-minute bout clock, an optional team-relay match counter, and video recording of each action for instant replay. It is a static PWA (React + TypeScript + Vite) served by Cloudflare Workers Static Assets. Everything runs on the device; there is no backend.

Version 2 is a rewrite of the original Flutter mobile app (v1.0.8, still in git history).

## Development

```sh
npm install
npm run dev          # Vite dev server (camera requires localhost or HTTPS)
npm test             # Vitest
npm run typecheck
npm run lint
npm run preview      # production build served by `wrangler dev`
npm run deploy       # build + `wrangler deploy`
```

`VITE_APP_NAME_PREFIX` (optional) is appended to the Start/Stop label, replacing the old `appNamePrefix` dart-define.

To regenerate the PWA icons from `assets/icons/`, run `npm run icons`.

## Layout

| Path                            | Contents                                                                                                     |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `src/domain/`                   | Pure scoring rules: scores, clock, match number, match-up table. No UI or I/O.                               |
| `src/state/`                    | Zustand stores: the bout (`matchStore`), persisted settings, toast.                                          |
| `src/services/`                 | Browser APIs: camera/recording (`getUserMedia` + `MediaRecorder`) and saving videos.                         |
| `src/app/actions.ts`            | User intents that tie the clock, camera and settings together (the old controller).                          |
| `src/hooks/`                    | Clock ticking, page visibility, screen wake lock, camera lifetime.                                           |
| `src/components/`, `src/pages/` | UI.                                                                                                          |
| `src/i18n/`                     | English, Japanese and French strings. `en.ts` defines the keys; other languages are type-checked against it. |

## Behaviour notes

- Any touch (+/−/Double) or Reset stops the clock and the recording. Start/Stop toggles both.
- Only the latest recording is kept, in memory. "Save" uses the share sheet when available (on phones this offers saving to the photo library), otherwise a download. Autosave always downloads.
- The bout clock is derived from elapsed time, so it does not drift. It pauses when the page goes to the background, and the screen stays on while it runs.

## Adding a translation

Add `src/i18n/<lang>.ts` typed as `Messages`, then register it in `src/i18n/index.ts`.
