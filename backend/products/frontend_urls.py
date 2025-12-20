from django.urls import path
from .frontend_views import (
    ProductManageListView,
    ProductManageCreateView,
    ProductManageUpdateView,
    ProductManageDeleteView,
)

app_name = "products_manage"

urlpatterns = [
    path("products/", ProductManageListView.as_view(), name="products_manage_list"),
    path("products/add/", ProductManageCreateView.as_view(), name="products_manage_add"),
    path("products/<int:pk>/edit/", ProductManageUpdateView.as_view(), name="products_manage_edit"),
    path("products/<int:pk>/delete/", ProductManageDeleteView.as_view(), name="products_manage_delete"),
]
