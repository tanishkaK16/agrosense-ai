"""Django settings for AgroSense AI backend."""
import os
import re
from pathlib import Path
from dotenv import load_dotenv

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# Load environment variables from .env file if present
ENV_FILE = BASE_DIR / ".env"
if ENV_FILE.exists():
    load_dotenv(ENV_FILE)

# ── Security & Debug ─────────────────────────────────────────────────────────

SECRET_KEY = os.getenv(
    "DJANGO_SECRET_KEY",
    "django-insecure-development-only-change-in-production-agrosense",
)

DEBUG = os.getenv("DJANGO_DEBUG", "true").lower() in ("true", "1", "yes")

allowed_hosts_raw = os.getenv("DJANGO_ALLOWED_HOSTS", "127.0.0.1,localhost,10.0.2.2")
ALLOWED_HOSTS = [host.strip() for host in allowed_hosts_raw.split(",") if host.strip()]

# ── GeoDjango / GDAL & GEOS Libraries ─────────────────────────────────────────

GDAL_LIBRARY_PATH = os.getenv("GDAL_LIBRARY_PATH")
GEOS_LIBRARY_PATH = os.getenv("GEOS_LIBRARY_PATH")

if not GDAL_LIBRARY_PATH:
    for candidate in [
        "/opt/homebrew/lib/libgdal.dylib",
        "/usr/local/lib/libgdal.dylib",
        "/opt/anaconda3/lib/python3.13/site-packages/rasterio/.dylibs/libgdal.38.3.12.1.dylib",
    ]:
        if os.path.exists(candidate):
            GDAL_LIBRARY_PATH = candidate
            break

if not GEOS_LIBRARY_PATH:
    import glob
    geos_candidates = [
        "/opt/homebrew/lib/libgeos_c.dylib",
        "/usr/local/lib/libgeos_c.dylib",
    ] + glob.glob(
        str(BASE_DIR / ".venv/**/libgeos_c*.dylib"),
        recursive=True,
        include_hidden=True,
    )
    for candidate in geos_candidates:
        if os.path.exists(candidate):
            GEOS_LIBRARY_PATH = candidate
            break

# ── Application Definition ───────────────────────────────────────────────────

INSTALLED_APPS = [
    # Core Django apps
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    # GIS and GeoDjango
    "django.contrib.gis",
    # Third-party packages
    "rest_framework",
    "corsheaders",
    # AgroSense domain apps
    "apps.common",
    "apps.accounts",
    "apps.fields",
    "apps.alerts",
    "apps.ingest",
]

MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "config.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "config.wsgi.application"
ASGI_APPLICATION = "config.asgi.application"

# ── Database Configuration ───────────────────────────────────────────────────
# Default: PostgreSQL with PostGIS extension (matching docker-compose.yml).
# Documented Fallback: Set DJANGO_USE_SQLITE=true for lightweight local tests
# when PostGIS / GDAL services are not running.

USE_SQLITE = os.getenv("DJANGO_USE_SQLITE", "false").lower() in ("true", "1", "yes")

if USE_SQLITE:
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": BASE_DIR / "db.sqlite3",
        }
    }
else:
    db_url = os.getenv("DATABASE_URL")
    if db_url:
        import urllib.parse
        parsed = urllib.parse.urlparse(db_url)
        DATABASES = {
            "default": {
                "ENGINE": os.getenv(
                    "DJANGO_DB_ENGINE",
                    "django.contrib.gis.db.backends.postgis",
                ),
                "NAME": parsed.path.lstrip("/"),
                "USER": parsed.username or "agrosense",
                "PASSWORD": parsed.password or "agrosense",
                "HOST": parsed.hostname or "127.0.0.1",
                "PORT": str(parsed.port or 5432),
            }
        }
    else:
        DATABASES = {
            "default": {
                "ENGINE": os.getenv(
                    "DJANGO_DB_ENGINE",
                    "django.contrib.gis.db.backends.postgis",
                ),
                "NAME": os.getenv("POSTGRES_DB", "agrosense"),
                "USER": os.getenv("POSTGRES_USER", "agrosense"),
                "PASSWORD": os.getenv("POSTGRES_PASSWORD", "agrosense"),
                "HOST": os.getenv("POSTGRES_HOST", "127.0.0.1"),
                "PORT": os.getenv("POSTGRES_PORT", "5432"),
            }
        }

# ── Password Validation ──────────────────────────────────────────────────────

AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
    },
]

# ── Internationalization & Timezone ──────────────────────────────────────────

LANGUAGE_CODE = "en-us"
TIME_ZONE = "Asia/Kolkata"
USE_I18N = True
USE_TZ = True

# ── Static Files ─────────────────────────────────────────────────────────────

STATIC_URL = "static/"
STATIC_ROOT = BASE_DIR / "staticfiles"

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# ── Django REST Framework ────────────────────────────────────────────────────

REST_FRAMEWORK = {
    "DEFAULT_RENDERER_CLASSES": [
        "rest_framework.renderers.JSONRenderer",
        "rest_framework.renderers.BrowsableAPIRenderer",
    ],
    "DEFAULT_PARSER_CLASSES": [
        "rest_framework.parsers.JSONParser",
        "rest_framework.parsers.FormParser",
        "rest_framework.parsers.MultiPartParser",
    ],
}

# ── CORS Headers ─────────────────────────────────────────────────────────────

cors_origins_raw = os.getenv(
    "CORS_ALLOWED_ORIGINS",
    "http://127.0.0.1:*,http://localhost:*",
)

CORS_ALLOWED_ORIGINS = []
CORS_ALLOWED_ORIGIN_REGEXES = []

for origin in cors_origins_raw.split(","):
    cleaned = origin.strip()
    if not cleaned:
        continue
    if "*" in cleaned:
        # Convert wildcard like http://localhost:* to regex pattern
        regex_pattern = "^" + re.escape(cleaned).replace(r"\*", r".*") + "$"
        CORS_ALLOWED_ORIGIN_REGEXES.append(regex_pattern)
    else:
        CORS_ALLOWED_ORIGINS.append(cleaned)

if DEBUG and not CORS_ALLOWED_ORIGINS and not CORS_ALLOWED_ORIGIN_REGEXES:
    CORS_ALLOW_ALL_ORIGINS = True
