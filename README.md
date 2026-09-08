# AgroSense AI

Satellite + weather + soil data turned into early crop-stress warnings for smallholder farmers.

## Repository layout

```
agrosense-ai/
  frontend/   Flutter farmer app (this is what farmers use)
  backend/    Teammate API (Python / FastAPI — separate workstream)
  docs/       Design specs, API contracts, release notes
```

## Running the farmer app

```bash
cd frontend
flutter pub get
flutter gen-l10n
flutter run
```

Targets: Android (primary). iOS builds but is not the launch platform.

## Environment variables

Copy `frontend/.env.example` to `frontend/.env` and fill in values before running against a real backend. Phase 0 does not read any env vars.

## Contributing

- All app code lives under `frontend/lib/`
- Localization strings: `frontend/lib/l10n/` — add keys to all three ARB files (en, hi, mr)
- Design tokens: `frontend/lib/core/theme/`
- Do not commit `.env` — it is in `.gitignore`
