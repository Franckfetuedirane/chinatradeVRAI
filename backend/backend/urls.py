from django.contrib import admin
from django.urls import path, include
from django.views.generic.base import RedirectView
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", include("products.urls")),
    # Redirect root to the public products API for convenience in dev
    path("", RedirectView.as_view(url="/api/products/", permanent=False)),
]

# # Serve media files in development
# if settings.DEBUG:
#     urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

# # Lightweight manage UI
# urlpatterns += [
#     path("manage/", include("products.frontend_urls")),
# ]
# Serve media files in development