from django.urls import path
from .frontend_views import (
    ManageLoginView,
    ManageLogoutView,
    ProductManageDashboardView,
    ProductManageListView,
    ProductManageDetailView,
    ProductManageCreateView,
    ProductManageUpdateView,
    ProductManageDeleteView,
    ProductManageDuplicateView,
    ProductManageBulkActionView,
    ProductManageExportCSVView,
    ProductManageImportCSVView,
)

app_name = "products_manage"

urlpatterns = [
    path("login/", ManageLoginView.as_view(), name="manage_login"),
    path("logout/", ManageLogoutView.as_view(), name="manage_logout"),
    path("", ProductManageDashboardView.as_view(), name="dashboard"),
    path("products/", ProductManageListView.as_view(), name="products_manage_list"),
    path("products/actions/", ProductManageBulkActionView.as_view(), name="products_manage_actions"),
    path("products/export/", ProductManageExportCSVView.as_view(), name="products_manage_export"),
    path("products/import/", ProductManageImportCSVView.as_view(), name="products_manage_import"),
    path("products/add/", ProductManageCreateView.as_view(), name="products_manage_add"),
    path("products/<int:pk>/", ProductManageDetailView.as_view(), name="products_manage_detail"),
    path("products/<int:pk>/duplicate/", ProductManageDuplicateView.as_view(), name="products_manage_duplicate"),
    path("products/<int:pk>/edit/", ProductManageUpdateView.as_view(), name="products_manage_edit"),
    path("products/<int:pk>/delete/", ProductManageDeleteView.as_view(), name="products_manage_delete"),
]
