# AgroSense AI — Backend API (Django + PostGIS)

Backend API service for AgroSense AI, providing authentication, field boundary telemetry, crop stress alerts, and farmer home snapshots.

The API adheres to the contract defined in `../docs/api-contract.md`.

---

## Tech Stack

- Python 3.12+
- Django 5.1
- Django REST Framework 3.15
- django-cors-headers
- PostgreSQL 16 + PostGIS 3.4 (via Docker Compose)
- GeoDjango (`django.contrib.gis`)

---

## Local Setup

### 1. Create and Activate Virtual Environment

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

For testing and local development utilities:
```bash
pip install -r requirements-dev.txt
```

### 3. Configure Environment

Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

Generate a secure secret key if needed:
```bash
python3 -c "import secrets; print(secrets.token_urlsafe(50))"
```

Set the generated key in `.env`:
```env
DJANGO_SECRET_KEY=your-generated-key-here
DJANGO_DEBUG=true
DJANGO_ALLOWED_HOSTS=127.0.0.1,localhost,10.0.2.2
POSTGRES_DB=agrosense
POSTGRES_USER=agrosense
POSTGRES_PASSWORD=agrosense
POSTGRES_HOST=127.0.0.1
POSTGRES_PORT=5432
CORS_ALLOWED_ORIGINS=http://127.0.0.1:*,http://localhost:*
```

### 4. Start PostGIS Service

Start the local PostgreSQL + PostGIS database container:
```bash
docker compose up -d
```

Verify the database container is running:
```bash
docker compose ps
```

### 5. Apply Migrations

```bash
python manage.py migrate
```

### 6. Start Development Server

```bash
python manage.py runserver 0.0.0.0:8000
```

The service will be reachable at `http://127.0.0.1:8000`.

---

## Health Check

Verify the service is active:
```bash
curl http://127.0.0.1:8000/api/v1/health/
```

Response (`200 OK`):
```json
{
  "status": "ok",
  "service": "agrosense-api"
}
```

---

## Running Tests

Run the test suite:
```bash
python manage.py test
```

If testing in a minimal environment without an active PostGIS container:
```bash
DJANGO_USE_SQLITE=true python manage.py test
```

---

## Local Development Fallback (SQLite)

The production and default configuration uses PostgreSQL with PostGIS (`django.contrib.gis.db.backends.postgis`).

If running on a machine without Docker or local PostGIS/GDAL libraries, activate the documented fallback:
```env
DJANGO_USE_SQLITE=true
```
This configures standard SQLite for local development and unit tests.

---

## API Endpoints (Phase 0 Foundation)

Base URL: `/api/v1/`

| Method | Endpoint | Phase 0 Status | Reference |
|---|---|---|---|
| `GET` | `/api/v1/health/` | `200 OK` | Container and health probes |
| `POST` | `/api/v1/auth/otp/request` | `501 Not Implemented` | OTP request (Phase 1) |
| `POST` | `/api/v1/auth/otp/verify` | `501 Not Implemented` | OTP verification (Phase 1) |
| `GET` | `/api/v1/me` | `501 Not Implemented` | Farmer profile (Phase 1) |
| `PUT` | `/api/v1/me` | `501 Not Implemented` | Farmer profile update (Phase 1) |
| `GET` | `/api/v1/fields` | `501 Not Implemented` | List farmer fields (Phase 2+) |
| `POST` | `/api/v1/fields` | `501 Not Implemented` | Register field (Phase 2+) |
| `GET` | `/api/v1/fields/{id}` | `501 Not Implemented` | Field details (Phase 2+) |
| `GET` | `/api/v1/fields/{id}/status` | `501 Not Implemented` | Field telemetry (Phase 2+) |
| `GET` | `/api/v1/home` | `501 Not Implemented` | Home snapshot (Phase 2+) |
| `GET` | `/api/v1/alerts` | `501 Not Implemented` | List alerts (Phase 2+) |
| `GET` | `/api/v1/alerts/{id}` | `501 Not Implemented` | Alert details (Phase 2+) |
| `POST` | `/api/v1/alerts/{id}/seen` | `501 Not Implemented` | Acknowledge alert (Phase 2+) |

---

## Project Structure

```
backend/
  manage.py                   # Django CLI utility
  requirements.txt            # Production dependencies
  requirements-dev.txt        # Development and testing dependencies
  .env.example                # Sample environment configuration
  docker-compose.yml          # PostGIS container definition
  README.md                   # This file
  config/                     # Django project configuration
    settings.py               # Env-based settings
    urls.py                   # Root URL router (/api/v1/)
    wsgi.py                   # WSGI application entrypoint
    asgi.py                   # ASGI application entrypoint
  apps/
    common/                   # Health checks and shared utilities
    accounts/                 # Authentication, OTP, and farmer profile
    fields/                   # Field registration and telemetry
    alerts/                   # Crop stress notifications
    ingest/                   # Satellite and weather data pipelines
  docs/                       # Documentation pointer to ../docs/api-contract.md
```
