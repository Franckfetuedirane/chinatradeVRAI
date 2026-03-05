from django.contrib import admin
from django.urls import path, include, re_path
from django.http import HttpResponse
from django.http import Http404
from django.views.generic.base import RedirectView
from django.conf import settings
from django.conf.urls.static import static
from django.views.static import serve

def health(request):
    return HttpResponse("FOESA backend OK")


def admin_login_gate(request, *args, **kwargs):
    next_url = (request.GET.get("next") or "").strip()
    if next_url in {"/admin", "/admin/"}:
        raise Http404("Not Found")
    return admin.site.login(request, *args, **kwargs)

urlpatterns = [
    path("admin/login/", admin_login_gate, name="admin_login_gate"),
    path("admin/", admin.site.urls),
    path("api/", include("products.urls")),
    path("manage/", include("products.frontend_urls")),
    path("", RedirectView.as_view(url="/api/products/", permanent=False)),  # changed root to API
]

# # Serve media files in development
# if settings.DEBUG:
#     urlpatterns += [
#         path("manage/", include("products.frontend_urls")),
#     ]


if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
elif getattr(settings, "SERVE_MEDIA", False):
    urlpatterns += [
        re_path(r"^media/(?P<path>.*)$", serve, {"document_root": settings.MEDIA_ROOT}),
    ]

# # Lightweight manage UI
# urlpatterns += [
#     path("manage/", include("products.frontend_urls")),
# ]
# Serve media files in development


