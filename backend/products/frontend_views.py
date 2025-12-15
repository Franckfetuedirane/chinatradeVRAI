from django.urls import reverse_lazy
from django.views.generic import ListView, CreateView, UpdateView, DeleteView
from django.shortcuts import redirect
from .models import Product
from .forms import ProductForm


class ProductManageListView(ListView):
    model = Product
    template_name = "products/product_list.html"
    context_object_name = "products"


class ProductManageCreateView(CreateView):
    model = Product
    form_class = ProductForm
    template_name = "products/product_form.html"
    success_url = reverse_lazy("products_manage:products_manage_list")


class ProductManageUpdateView(UpdateView):
    model = Product
    form_class = ProductForm
    template_name = "products/product_form.html"
    success_url = reverse_lazy("products_manage:products_manage_list")


class ProductManageDeleteView(DeleteView):
    model = Product
    template_name = "products/product_confirm_delete.html"
    success_url = reverse_lazy("products_manage:products_manage_list")
