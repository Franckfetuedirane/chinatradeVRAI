from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse
from django.views.generic.base import RedirectView
from django.conf import settings
from django.conf.urls.static import static

def health(request):
    return HttpResponse("China Trade Master backend OK")

urlpatterns = [
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

# # Lightweight manage UI
# urlpatterns += [
#     path("manage/", include("products.frontend_urls")),
# ]
# Serve media files in development
