# Stack profile: scriptony-desktop

Read with `AGENTS.md` and `.cursor/rules/scriptony-desktop-dev.mdc`.

## Runtime axes (3 Achsen)

| Axis | Default | Intake questions |
|------|---------|------------------|
| Shell | Tauri desktop | WebView only — not browser `npm run dev` |
| Cloud session | Optional hybrid | `canUseCloudSession()` — KI/TTS/sync |
| Data | Local `.scriptony` + SQLite | `dispatchByRuntime` / `LocalBackend` |

## Code paths

| Concern | Prefer |
|---------|--------|
| Project/timeline data | `src/lib/api-adapter/` + `dispatchByRuntime` |
| New UI | `src/components/`, hooks in `src/hooks/` |
| Cloud-only APIs | Extend local adapter first — see `docs/DESKTOP_FIRST_DEV.md` |
| TTS/audio jobs | `functions/scriptony-audio*`, `scriptony-audio-story` |
| Characters/voices | `src/lib/types/audio.ts`, `CharacterVoiceSelector`, `LocalAudioRepository` |
| Timeline audio | `src/components/audio/`, `src/components/structure/timeline/` |

## Checks (desktop ticket)

```bash
CHECK_MODE=snippet SHIM_CHECKS_ARGS="--frontend" SHIM_CHANGED_FILES="<paths>" npm run checks
```

Skip Appwrite deploy / `verify:test-env` unless ticket is cloud/hybrid.

## Dev

```bash
docker stop scriptony-frontend 2>/dev/null || true
npm run dev:desktop
```

Port 3000 = Tauri WebView HMR, not public web app.

## UI

- Tailwind + Radix (not DaisyUI)
- German UI copy
- Loading / empty / error states required

## Issue slicing bias

1. Local schema + `LocalBackend` persistence
2. UI in existing audio/structure views
3. Cloud function + adapter in follow-up issue if hybrid required
