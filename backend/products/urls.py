from django.urls import path
from .views import ProductListAPIView
from .auth_views import csrf, login_view, logout_view, me, register

urlpatterns = [
    path("products/", ProductListAPIView.as_view(), name="product-list"),
    path("auth/csrf/", csrf, name="auth-csrf"),
    path("auth/me/", me, name="auth-me"),
    path("auth/register/", register, name="auth-register"),
    path("auth/login/", login_view, name="auth-login"),
    path("auth/logout/", logout_view, name="auth-logout"),
]
