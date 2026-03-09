import json
import time

from django.contrib.auth import authenticate, get_user_model, login, logout
from django.http import JsonResponse
from django.middleware.csrf import get_token
from django.views.decorators.csrf import ensure_csrf_cookie
from django.views.decorators.http import require_GET, require_POST

User = get_user_model()


def _json_body(request):
    try:
        return json.loads(request.body.decode("utf-8") or "{}")
    except Exception:
        return {}


def _serialize_user(user):
    return {
        "id": user.id,
        "username": user.username,
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
    }


@require_GET
@ensure_csrf_cookie
def csrf(request):
    return JsonResponse({"detail": "CSRF cookie set", "csrfToken": get_token(request)})


@require_GET
def me(request):
    if not request.user.is_authenticated:
        return JsonResponse({"authenticated": False, "user": None})
    return JsonResponse({"authenticated": True, "user": _serialize_user(request.user)})


@require_POST
def register(request):
    data = _json_body(request)
    email = (data.get("email") or "").strip().lower()
    password = data.get("password") or ""
    username = (data.get("username") or email).strip().lower()
    first_name = (data.get("first_name") or "").strip()
    last_name = (data.get("last_name") or "").strip()

    if not email or "@" not in email:
        return JsonResponse({"detail": "Email invalide."}, status=400)
    if len(password) < 8:
        return JsonResponse({"detail": "Le mot de passe doit contenir au moins 8 caracteres."}, status=400)
    if not username:
        return JsonResponse({"detail": "Nom d'utilisateur invalide."}, status=400)
    if User.objects.filter(username=username).exists():
        return JsonResponse({"detail": "Ce nom d'utilisateur existe deja."}, status=400)
    if User.objects.filter(email=email).exists():
        return JsonResponse({"detail": "Cet email est deja utilise."}, status=400)

    user = User.objects.create_user(
        username=username,
        email=email,
        password=password,
        first_name=first_name,
        last_name=last_name,
    )
    login(request, user)
    request.session["last_activity"] = int(time.time())
    return JsonResponse({"detail": "Inscription reussie.", "user": _serialize_user(user)}, status=201)


@require_POST
def login_view(request):
    data = _json_body(request)
    identity = (data.get("username") or data.get("email") or "").strip().lower()
    password = data.get("password") or ""
    if not identity or not password:
        return JsonResponse({"detail": "Identifiants invalides."}, status=400)

    username = identity
    if "@" in identity:
        user = User.objects.filter(email__iexact=identity).only("username").first()
        if user:
            username = user.username

    user = authenticate(request, username=username, password=password)
    if not user:
        return JsonResponse({"detail": "Email/username ou mot de passe incorrect."}, status=401)

    login(request, user)
    request.session["last_activity"] = int(time.time())
    return JsonResponse({"detail": "Connexion reussie.", "user": _serialize_user(user)})


@require_POST
def logout_view(request):
    logout(request)
    return JsonResponse({"detail": "Deconnexion reussie."})
