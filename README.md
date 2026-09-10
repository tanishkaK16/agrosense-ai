# AgroSense AI

AgroSense AI delivers early crop-stress warnings and actionable recommendations directly to smallholder farmers. By synthesizing satellite data, hyper-local weather models, and soil observations into simple, high-contrast health meters, the system helps farmers take timely action against drought, pest outbreaks, and irrigation stress before crop damage spreads.

---

## Repository Structure

```
agrosense-ai/
  frontend/   Flutter farmer mobile app (offline-first, voice-assisted, sunlight-readable)
  backend/    Teammate API workstream (Django / FastAPI services and satellite pipelines)
  docs/       Technical specifications and backend API contract (api-contract.md)
```

- **`frontend/`**: The complete farmer mobile application built in Flutter. Contains all Phase 0 through Phase 10 implementations including offline caching, voice assistance, multi-language support, and accessible text sizing.
- **`backend/`**: Backend services workstream (Django REST API endpoints for authentication, fields, health status, and alert generation).
- **`docs/`**: Documentation for backend team integration, including `docs/api-contract.md`.

---

## Running the Farmer App

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate localization files:
   ```bash
   flutter gen-l10n
   ```

4. Run the app with local mock/offline fallback (default):
   ```bash
   flutter run --dart-define=API_USE_LIVE=false
   ```

5. Run against a live backend server:
   ```bash
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api --dart-define=API_USE_LIVE=true
   ```

---

## Running the Backend API

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Create and activate a virtual environment:
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Configure environment:
   ```bash
   cp .env.example .env
   ```

5. Start the PostGIS database container:
   ```bash
   docker compose up -d
   ```

6. Apply database migrations:
   ```bash
   python manage.py migrate
   ```

7. Run the development server:
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

8. Verify the health check:
   ```bash
   curl http://127.0.0.1:8000/api/v1/health/
   ```

> **Android Emulator Note**: When connecting the Flutter app running on the Android emulator to the host Django backend, use `API_BASE_URL=http://10.0.2.2:8000`.

---

## Languages

The mobile client supports three languages with full on-device voice readouts and speech commands:
- English (`en`)
- Hindi (`hi`)
- Marathi (`mr`)

Farmers can change language anytime on the onboarding screen, at the top of the sign-in screens, or in the Account tab.

---

## Demo Authentication

- Enter any valid 10-digit Indian mobile number (e.g., `9876543210`).
- Verification OTP code: **`1234`**.

---

## Environment Configuration

Copy `.env.example` to `.env` to customize endpoints:

```bash
cp .env.example .env
```

Default settings:
```
API_BASE_URL=http://127.0.0.1:8000
API_USE_LIVE=false
```
