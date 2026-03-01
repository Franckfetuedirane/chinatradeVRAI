from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView, UpdateView, DeleteView
from django.conf import settings
import logging
from .models import Product
from .forms import ProductForm

logger = logging.getLogger(__name__)


class ProductManageListView(ListView):
    model = Product
    template_name = "products/product_list.html"
    context_object_name = "products"


class ProductManageCreateView(CreateView):
    model = Product
    form_class = ProductForm
    template_name = "products/product_form.html"
    success_url = reverse_lazy("products_manage:products_manage_list")

    def form_valid(self, form):
        try:
            return super().form_valid(form)
        except Exception as e:
            logger.exception("Product create failed")
            # Avoid raw 500 in admin-lite UI; show actionable error in form.
            if not getattr(settings, "CLOUDINARY_ENABLED", False):
                form.add_error(
                    "image",
                    "Upload image indisponible: configuration Cloudinary manquante ou invalide.",
                )
            else:
                form.add_error(None, f"Erreur lors de l'enregistrement: {e}")
            return self.form_invalid(form)


class ProductManageUpdateView(UpdateView):
    model = Product
    form_class = ProductForm
    template_name = "products/product_form.html"
    success_url = reverse_lazy("products_manage:products_manage_list")

    def form_valid(self, form):
        try:
            return super().form_valid(form)
        except Exception as e:
            logger.exception("Product update failed")
            if not getattr(settings, "CLOUDINARY_ENABLED", False):
                form.add_error(
                    "image",
                    "Upload image indisponible: configuration Cloudinary manquante ou invalide.",
                )
            else:
                form.add_error(None, f"Erreur lors de l'enregistrement: {e}")
            return self.form_invalid(form)


class ProductManageDeleteView(DeleteView):
    model = Product
    template_name = "products/product_confirm_delete.html"
    success_url = reverse_lazy("products_manage:products_manage_list")

# def manage_products(request):
#     return render(request, "products/product_list.html")
