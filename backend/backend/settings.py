from pathlib import Path
import os
import secrets

import dj_database_url

# Optional local .env loading (do not crash if python-dotenv is missing)
try:
    from dotenv import load_dotenv
    load_dotenv()
except Exception:
    pass


BASE_DIR = Path(__file__).resolve().parent.parent


def _parse_bool(value: str, default: bool = False) -> bool:
    if value is None:
        return default
    return str(value).strip().lower() in {"1", "true", "yes", "on"}


def _parse_csv(value: str) -> list[str]:
    if not value:
        return []
    return [x.strip() for x in value.split(",") if x.strip()]


DEBUG = _parse_bool(os.environ.get("DEBUG"), default=True)

SECRET_KEY = os.environ.get("SECRET_KEY")
if not SECRET_KEY:
    if DEBUG:
        SECRET_KEY = secrets.token_urlsafe(50)
    else:
        raise RuntimeError("SECRET_KEY must be set when DEBUG=False")

ALLOWED_HOSTS = _parse_csv(os.environ.get("ALLOWED_HOSTS", ""))
if not ALLOWED_HOSTS:
    ALLOWED_HOSTS = ["*"] if DEBUG else [
        "alluring-art-production-5c03.up.railway.app",
        "localhost",
        "127.0.0.1",
    ]

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "rest_framework",
    "corsheaders",
    "products",
    "cloudinary",
    "cloudinary_storage",
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

ROOT_URLCONF = "backend.urls"

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

WSGI_APPLICATION = "backend.wsgi.application"

DATABASE_URL = os.environ.get("DATABASE_URL", "")
_is_postgres_url = DATABASE_URL.startswith("postgres://") or DATABASE_URL.startswith("postgresql://")

DATABASES = {
    "default": dj_database_url.config(
        default=f"sqlite:///{BASE_DIR / 'db.sqlite3'}",
        conn_max_age=600,
        # Only ask SSL for Postgres URLs. SQLite does not support sslmode.
        ssl_require=_is_postgres_url,
    )
}

AUTH_PASSWORD_VALIDATORS = []

LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True

STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "staticfiles"

MEDIA_URL = "/media/"
MEDIA_ROOT = BASE_DIR / "media"

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# CORS
if DEBUG:
    CORS_ALLOW_ALL_ORIGINS = True
else:
    CORS_ALLOW_ALL_ORIGINS = False
    CORS_ALLOWED_ORIGINS = _parse_csv(os.environ.get("CORS_ALLOWED_ORIGINS", ""))
CORS_ALLOW_CREDENTIALS = True

# CSRF
_default_csrf = [
    "https://alluring-art-production-5c03.up.railway.app",
    "http://127.0.0.1:8000",
    "http://localhost:8000",
]
CSRF_TRUSTED_ORIGINS = _default_csrf + _parse_csv(os.environ.get("CSRF_TRUSTED_ORIGINS", ""))

# Proxy/HTTPS
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
if not DEBUG:
    CSRF_COOKIE_SECURE = True
    SESSION_COOKIE_SECURE = True

REST_FRAMEWORK = {
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.AllowAny",
    ]
}

# Cloudinary config
CLOUDINARY_URL = os.environ.get("CLOUDINARY_URL")
CLOUDINARY_CLOUD_NAME = os.environ.get("CLOUDINARY_CLOUD_NAME")
CLOUDINARY_API_KEY = os.environ.get("CLOUDINARY_API_KEY")
CLOUDINARY_API_SECRET = os.environ.get("CLOUDINARY_API_SECRET")

_cloudinary_configured = False
try:
    import cloudinary

    if CLOUDINARY_URL:
        cloudinary.config(cloudinary_url=CLOUDINARY_URL, secure=True)
        _cloudinary_configured = True
    elif all([CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET]):
        cloudinary.config(
            cloud_name=CLOUDINARY_CLOUD_NAME,
            api_key=CLOUDINARY_API_KEY,
            api_secret=CLOUDINARY_API_SECRET,
            secure=True,
        )
        _cloudinary_configured = True
except Exception:
    _cloudinary_configured = False

if _cloudinary_configured:
    DEFAULT_FILE_STORAGE = "cloudinary_storage.storage.MediaCloudinaryStorage"
else:
    DEFAULT_FILE_STORAGE = "django.core.files.storage.FileSystemStorage"

# Expose Cloudinary availability for form-level validation.
CLOUDINARY_ENABLED = _cloudinary_configured
