from pathlib import Path
import os
import secrets
from django.core.exceptions import ImproperlyConfigured
import dj_database_url
from dotenv import load_dotenv

# 🔹 Charger les variables locales si présentes (.env)
load_dotenv()

# 🔹 Base directory
BASE_DIR = Path(__file__).resolve().parent.parent

# 🔹 SECRET_KEY
SECRET_KEY = os.environ.get("SECRET_KEY")
if not SECRET_KEY:
    if os.environ.get("DEBUG", "True").lower() == "true":
        # clé temporaire pour dev local
        SECRET_KEY = secrets.token_urlsafe(50)
    else:
        raise ImproperlyConfigured("The SECRET_KEY environment variable must be set in production.")

# 🔹 DEBUG
DEBUG = os.environ.get("DEBUG", "False").lower() == "true"

# 🔹 Allowed hosts
ALLOWED_HOSTS = os.environ.get("ALLOWED_HOSTS", "*").split(",") if not DEBUG else ["*"]

# 🔹 Applications
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

# 🔹 Middleware
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

# 🔹 Templates
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

# 🔹 Database
DATABASES = {
    "default": dj_database_url.config(
        default=f"sqlite:///{BASE_DIR / 'db.sqlite3'}",
        conn_max_age=600,
        ssl_require=not DEBUG,
    )
}

AUTH_PASSWORD_VALIDATORS = []

LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True

# 🔹 Static & Media
STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "staticfiles"
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

MEDIA_ROOT = BASE_DIR / "media"
MEDIA_URL = "/media/"

# 🔹 CORS
CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True

# 🔹 CSRF
CSRF_TRUSTED_ORIGINS = [
    "https://alluring-art-production-5c03.up.railway.app",
    "http://127.0.0.1:8000",
    "http://localhost:8000",
] + [x.strip() for x in os.environ.get("CSRF_TRUSTED_ORIGINS", "").split(",") if x.strip()]

# 🔹 HTTPS behind proxy
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
if not DEBUG:
    CSRF_COOKIE_SECURE = True
    SESSION_COOKIE_SECURE = True

# 🔹 REST Framework
REST_FRAMEWORK = {
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.AllowAny",
    ]
}

# 🔹 Cloudinary
CLOUDINARY_CLOUD_NAME = os.environ.get("CLOUDINARY_CLOUD_NAME")
CLOUDINARY_API_KEY = os.environ.get("CLOUDINARY_API_KEY")
CLOUDINARY_API_SECRET = os.environ.get("CLOUDINARY_API_SECRET")

if all([CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET]):
    import cloudinary
    cloudinary.config(
        cloud_name=CLOUDINARY_CLOUD_NAME,
        api_key=CLOUDINARY_API_KEY,
        api_secret=CLOUDINARY_API_SECRET,
        secure=True,
    )
    DEFAULT_FILE_STORAGE = "cloudinary_storage.storage.MediaCloudinaryStorage"
else:
    if not DEBUG:
        raise ImproperlyConfigured(
            "Cloudinary credentials are required in production. "
            "Set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET."
        )
    DEFAULT_FILE_STORAGE = "django.core.files.storage.FileSystemStorage"

# 🔹 Optional: debug Cloudinary in local dev
if DEBUG:
    print("===== CLOUDINARY DEBUG =====")
    print("DEBUG:", DEBUG)
    print("CLOUD NAME:", CLOUDINARY_CLOUD_NAME)
    print("API KEY:", CLOUDINARY_API_KEY)
    print("API SECRET:", CLOUDINARY_API_SECRET)
    print("=============================")









# from pathlib import Path
# import os
# from django.core.exceptions import ImproperlyConfigured
# import secrets
# import dj_database_url

# from dotenv import load_dotenv
# load_dotenv()

# BASE_DIR = Path(__file__).resolve().parent.parent

# # SECRET_KEY = "changeme-for-dev"
# SECRET_KEY = os.environ.get("SECRET_KEY")
# #DEBUG = os.environ.get("DEBUG", "False").lower() == "true"
# # DEBUG = os.environ.get("DEBUG") == "True"
# DEBUG = os.environ.get("DEBUG", "True") == "True"

# # Provide a safe development fallback for SECRET_KEY; require env var in production
# if not SECRET_KEY:
#     if DEBUG:
#         # generate ephemeral key for local/dev only
#         SECRET_KEY = secrets.token_urlsafe(50)
#     else:
#         raise ImproperlyConfigured("The SECRET_KEY environment variable must be set in production.")

# ALLOWED_HOSTS = ['*']

# # DEBUG = True

# # ALLOWED_HOSTS = ["localhost", "127.0.0.1"]

# INSTALLED_APPS = [
#     "django.contrib.admin",
#     "django.contrib.auth",
#     "django.contrib.contenttypes",
#     "django.contrib.sessions",
#     "django.contrib.messages",
#     "django.contrib.staticfiles",
#     "rest_framework",
#     "corsheaders",
#     "products",
#     "cloudinary",
#     "cloudinary_storage",
# ]

# MIDDLEWARE = [
#     "corsheaders.middleware.CorsMiddleware",
#     "django.middleware.security.SecurityMiddleware",
#     "django.contrib.sessions.middleware.SessionMiddleware",
#     "django.middleware.common.CommonMiddleware",
#     "django.middleware.csrf.CsrfViewMiddleware",
#     "django.contrib.auth.middleware.AuthenticationMiddleware",
#     "django.contrib.messages.middleware.MessageMiddleware",
#     "django.middleware.clickjacking.XFrameOptionsMiddleware",
# ]

# ROOT_URLCONF = "backend.urls"

# TEMPLATES = [
#     {
#         "BACKEND": "django.template.backends.django.DjangoTemplates",
#         "DIRS": [],
#         "APP_DIRS": True,
#         "OPTIONS": {
#             "context_processors": [
#                 "django.template.context_processors.debug",
#                 "django.template.context_processors.request",
#                 "django.contrib.auth.context_processors.auth",
#                 "django.contrib.messages.context_processors.messages",
#             ],
#         },
#     },
# ]

# WSGI_APPLICATION = "backend.wsgi.application"

# # DATABASES = {
# #     "default": {
# #         "ENGINE": "django.db.backends.sqlite3",
# #         "NAME": BASE_DIR / "db.sqlite3",
# #     }
# # }

# DATABASES = {
#     "default": dj_database_url.config(
#         default=f"sqlite:///{BASE_DIR / 'db.sqlite3'}",
#         conn_max_age=600,
#         ssl_require=not DEBUG,
#     )
# }

# AUTH_PASSWORD_VALIDATORS = []

# LANGUAGE_CODE = "en-us"

# TIME_ZONE = "UTC"

# USE_I18N = True

# USE_TZ = True

# STATIC_URL = "/static/"

# # Directory where `collectstatic` will gather static files for deployment
# STATIC_ROOT = BASE_DIR / "staticfiles"

# DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# # CORS for local dev
# CORS_ALLOW_ALL_ORIGINS = True

# CORS_ALLOW_CREDENTIALS = True

# # CSRF trusted origins (required for HTTPS form POSTs behind custom domains/proxies)
# _default_csrf_trusted = [
#     "https://alluring-art-production-5c03.up.railway.app",
#     "http://127.0.0.1:8000",
#     "http://localhost:8000",
# ]
# _env_csrf = os.environ.get("CSRF_TRUSTED_ORIGINS", "")
# _extra_csrf = [o.strip() for o in _env_csrf.split(",") if o.strip()]
# CSRF_TRUSTED_ORIGINS = _default_csrf_trusted + _extra_csrf

# # Railway/proxy HTTPS support for secure cookies and request scheme detection
# SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
# if not DEBUG:
#     CSRF_COOKIE_SECURE = True
#     SESSION_COOKIE_SECURE = True

# # Django REST Framework minimal settings
# REST_FRAMEWORK = {
#     "DEFAULT_PERMISSION_CLASSES": [
#         "rest_framework.permissions.AllowAny",
#     ]
# }

# import cloudinary
# import cloudinary.uploader
# import cloudinary.api

# CLOUDINARY_CLOUD_NAME = os.environ.get("CLOUDINARY_CLOUD_NAME")
# CLOUDINARY_API_KEY = os.environ.get("CLOUDINARY_API_KEY")
# CLOUDINARY_API_SECRET = os.environ.get("CLOUDINARY_API_SECRET")

# _cloudinary_values = [
#     CLOUDINARY_CLOUD_NAME,
#     CLOUDINARY_API_KEY,
#     CLOUDINARY_API_SECRET,
# ]
# _cloudinary_configured = all(_cloudinary_values)
# _cloudinary_partially_configured = any(_cloudinary_values) and not _cloudinary_configured

# if _cloudinary_partially_configured:
#     raise ImproperlyConfigured(
#         "Cloudinary config is incomplete. Set CLOUDINARY_CLOUD_NAME, "
#         "CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET."
#     )

# # Product.image uses CloudinaryField; in production uploads require Cloudinary credentials.
# if not DEBUG and not _cloudinary_configured:
#     raise ImproperlyConfigured(
#         "Cloudinary credentials are required in production. "
#         "Set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET."
#     )

# if _cloudinary_configured:
#     cloudinary.config(
#         cloud_name=CLOUDINARY_CLOUD_NAME,
#         api_key=CLOUDINARY_API_KEY,
#         api_secret=CLOUDINARY_API_SECRET,
#         secure=True,
#     )
#     DEFAULT_FILE_STORAGE = "cloudinary_storage.storage.MediaCloudinaryStorage"
# else:
#     # local uniquement
#     MEDIA_ROOT = BASE_DIR / "media"
#     MEDIA_URL = "/media/"
#     DEFAULT_FILE_STORAGE = "django.core.files.storage.FileSystemStorage"


# #pour tester si cloudinary fonctionne bien

# # print("===== CLOUDINARY DEBUG =====")
# # print("DEBUG:", DEBUG)
# # print("CLOUD NAME:", os.environ.get("CLOUDINARY_CLOUD_NAME"))
# # print("API KEY:", os.environ.get("CLOUDINARY_API_KEY"))
# # print("API SECRET:", os.environ.get("CLOUDINARY_API_SECRET"))
# # print("=============================")