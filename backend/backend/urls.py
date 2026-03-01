from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse
from django.http import JsonResponse
from django.views.generic.base import RedirectView
from django.conf import settings
from django.conf.urls.static import static
import os

def health(request):
    return HttpResponse("China Trade Master backend OK")


def env_check(request):
    return JsonResponse({
        "DEBUG": settings.DEBUG,
        "CLOUDINARY_URL_SET": bool(os.environ.get("CLOUDINARY_URL")),
        "CLOUDINARY_CLOUD_NAME_SET": bool(os.environ.get("CLOUDINARY_CLOUD_NAME")),
        "CLOUDINARY_API_KEY_SET": bool(os.environ.get("CLOUDINARY_API_KEY")),
        "CLOUDINARY_API_SECRET_SET": bool(os.environ.get("CLOUDINARY_API_SECRET")),
        "SECRET_KEY_SET": bool(os.environ.get("SECRET_KEY")),
    })

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", include("products.urls")),
    path("manage/", include("products.frontend_urls")),
    path("env-check/", env_check),
    path("", RedirectView.as_view(url="/api/products/", permanent=False)),  # changed root to API
]

# # Serve media files in development
# if settings.DEBUG:
#     urlpatterns += [
#         path("manage/", include("products.frontend_urls")),
#     ]


if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

# # Lightweight manage UI
# urlpatterns += [
#     path("manage/", include("products.frontend_urls")),
# ]
# Serve media files in development
