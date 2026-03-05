import csv
from io import TextIOWrapper

from django.contrib import admin
from django.contrib import messages
from django.contrib.auth.mixins import LoginRequiredMixin
from django.contrib.auth.views import LoginView, LogoutView
from django.db.models import Q
from django.http import HttpResponse
from django.shortcuts import redirect
from django.urls import NoReverseMatch, reverse, reverse_lazy
from django.views import View
from django.views.generic import CreateView, DeleteView, DetailView, FormView, ListView, TemplateView, UpdateView

from .forms import ProductBulkActionForm, ProductForm, ProductImportForm
from .models import Category, Product


class ManageQueryMixin:
    def current_query(self):
        query = self.request.GET.copy()
        query.pop("page", None)
        return query.urlencode()

    def next_url(self, default_name="products_manage:products_manage_list"):
        nxt = self.request.POST.get("next") or self.request.GET.get("next")
        if nxt:
            return nxt
        base = reverse(default_name)
        query = self.current_query()
        return f"{base}?{query}" if query else base


class ManageLoginView(LoginView):
    template_name = "products/manage_login.html"
    redirect_authenticated_user = True

    def get_success_url(self):
        return self.get_redirect_url() or reverse("products_manage:dashboard")


class ManageLogoutView(LogoutView):
    next_page = reverse_lazy("products_manage:manage_login")


class ManageAccessMixin(LoginRequiredMixin):
    login_url = reverse_lazy("products_manage:manage_login")


class ProductManageDashboardView(ManageAccessMixin, TemplateView):
    template_name = "products/dashboard.html"

    def _get_admin_modules(self):
        modules = {}
        for model in admin.site._registry.keys():
            app_label = model._meta.app_label
            app_name = model._meta.app_config.verbose_name

            try:
                add_url = reverse(f"admin:{app_label}_{model._meta.model_name}_add")
            except NoReverseMatch:
                add_url = ""

            try:
                changelist_url = reverse(f"admin:{app_label}_{model._meta.model_name}_changelist")
            except NoReverseMatch:
                changelist_url = ""

            if not add_url and not changelist_url:
                continue

            modules.setdefault(
                app_label,
                {"app_name": app_name, "models": []},
            )
            modules[app_label]["models"].append(
                {
                    "name": model._meta.verbose_name_plural.title(),
                    "add_url": add_url,
                    "changelist_url": changelist_url,
                }
            )

        result = []
        for item in sorted(modules.values(), key=lambda x: x["app_name"].lower()):
            item["models"].sort(key=lambda x: x["name"].lower())
            result.append(item)
        return result

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        total = Product.objects.count()
        available = Product.objects.filter(status=Product.STATUS_AVAILABLE).count()
        out = Product.objects.filter(status=Product.STATUS_OUT).count()
        latest = Product.objects.order_by("-created_at")[:8]
        context.update(
            {
                "total_products": total,
                "available_products": available,
                "out_products": out,
                "latest_products": latest,
                "admin_modules": self._get_admin_modules(),
            }
        )
        return context


class ProductManageListView(ManageAccessMixin, ManageQueryMixin, ListView):
    model = Product
    template_name = "products/product_list.html"
    context_object_name = "products"
    paginate_by = 10

    def get_queryset(self):
        queryset = Product.objects.all()
        q = self.request.GET.get("q", "").strip()
        status = self.request.GET.get("status", "").strip()
        order = self.request.GET.get("order", "newest").strip()

        if q:
            queryset = queryset.filter(
                Q(name__icontains=q)
                | Q(category__name__icontains=q)
                | Q(description__icontains=q)
                | Q(country__icontains=q)
                | Q(city__icontains=q)
                | Q(phone__icontains=q)
                | Q(whatsapp__icontains=q)
                | Q(email__icontains=q)
            )

        if status in {Product.STATUS_AVAILABLE, Product.STATUS_OUT}:
            queryset = queryset.filter(status=status)

        if order == "oldest":
            queryset = queryset.order_by("created_at")
        elif order == "name_asc":
            queryset = queryset.order_by("name", "-created_at")
        elif order == "name_desc":
            queryset = queryset.order_by("-name", "-created_at")
        elif order == "status":
            queryset = queryset.order_by("status", "-created_at")
        else:
            queryset = queryset.order_by("-created_at")

        return queryset

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context.update(
            {
                "q": self.request.GET.get("q", "").strip(),
                "status_filter": self.request.GET.get("status", "").strip(),
                "order": self.request.GET.get("order", "newest").strip(),
                "query_string": self.current_query(),
                "bulk_form": ProductBulkActionForm(),
            }
        )
        return context


class ProductManageDetailView(ManageAccessMixin, ManageQueryMixin, DetailView):
    model = Product
    template_name = "products/product_detail.html"
    context_object_name = "product"

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["back_url"] = self.next_url()
        return context


class ProductManageCreateView(ManageAccessMixin, CreateView):
    model = Product
    form_class = ProductForm
    template_name = "products/product_form.html"
    success_url = reverse_lazy("products_manage:products_manage_list")

    def form_valid(self, form):
        response = super().form_valid(form)
        messages.success(self.request, "Produit ajoute avec succes.")
        return response

    def get_success_url(self):
        if "_save_and_add" in self.request.POST:
            return reverse("products_manage:products_manage_add")
        if "_save_and_continue" in self.request.POST:
            return reverse("products_manage:products_manage_edit", kwargs={"pk": self.object.pk})
        return self.success_url


class ProductManageUpdateView(ManageAccessMixin, ManageQueryMixin, UpdateView):
    model = Product
    form_class = ProductForm
    template_name = "products/product_form.html"
    success_url = reverse_lazy("products_manage:products_manage_list")

    def form_valid(self, form):
        response = super().form_valid(form)
        messages.success(self.request, "Produit mis a jour.")
        return response

    def get_success_url(self):
        if "_save_and_add" in self.request.POST:
            return reverse("products_manage:products_manage_add")
        if "_save_and_continue" in self.request.POST:
            return reverse("products_manage:products_manage_edit", kwargs={"pk": self.object.pk})
        return self.next_url()

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["back_url"] = self.next_url()
        return context


class ProductManageDeleteView(ManageAccessMixin, ManageQueryMixin, DeleteView):
    model = Product
    template_name = "products/product_confirm_delete.html"
    success_url = reverse_lazy("products_manage:products_manage_list")

    def form_valid(self, form):
        messages.success(self.request, "Produit supprime.")
        return super().form_valid(form)

    def get_success_url(self):
        return self.next_url()

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["back_url"] = self.next_url()
        return context


class ProductManageDuplicateView(ManageAccessMixin, View):
    def post(self, request, pk):
        source = Product.objects.get(pk=pk)
        clone = Product.objects.create(
            name=f"{source.name} (copie)",
            category=source.category,
            description=source.description,
            price=source.price,
            country=source.country,
            city=source.city,
            image=source.image,
            gallery_images=source.gallery_images,
            video_url=source.video_url,
            phone=source.phone,
            whatsapp=source.whatsapp,
            email=source.email,
            status=source.status,
        )
        messages.success(request, f"Produit duplique: {clone.name}")
        return redirect("products_manage:products_manage_edit", pk=clone.pk)


class ProductManageBulkActionView(ManageAccessMixin, View):
    def post(self, request):
        form = ProductBulkActionForm(request.POST)
        selected_ids = request.POST.getlist("selected")
        query = Product.objects.filter(pk__in=selected_ids)

        if not selected_ids:
            messages.warning(request, "Selection vide.")
            return redirect(reverse("products_manage:products_manage_list"))

        if not form.is_valid():
            messages.error(request, "Action invalide.")
            return redirect(reverse("products_manage:products_manage_list"))

        action = form.cleaned_data["action"]
        count = query.count()

        if action == ProductBulkActionForm.ACTION_AVAILABLE:
            query.update(status=Product.STATUS_AVAILABLE)
            messages.success(request, f"{count} produit(s) marques Available.")
        elif action == ProductBulkActionForm.ACTION_OUT:
            query.update(status=Product.STATUS_OUT)
            messages.success(request, f"{count} produit(s) marques Out of stock.")
        elif action == ProductBulkActionForm.ACTION_DELETE:
            query.delete()
            messages.success(request, f"{count} produit(s) supprimes.")

        next_url = request.POST.get("next") or reverse("products_manage:products_manage_list")
        return redirect(next_url)


class ProductManageExportCSVView(ManageAccessMixin, View):
    def get(self, request):
        response = HttpResponse(content_type="text/csv")
        response["Content-Disposition"] = 'attachment; filename="products_export.csv"'

        writer = csv.writer(response)
        writer.writerow(
            [
                "id",
                "name",
                "category",
                "description",
                "price",
                "country",
                "city",
                "image",
                "gallery_images",
                "video_url",
                "phone",
                "whatsapp",
                "email",
                "status",
                "created_at",
            ]
        )

        for p in Product.objects.all().order_by("-created_at"):
            writer.writerow(
                [
                    p.pk,
                    p.name,
                    p.category.name if p.category_id else "",
                    p.description,
                    p.price,
                    p.country,
                    p.city,
                    str(p.image or ""),
                    p.gallery_images,
                    p.video_url,
                    p.phone,
                    p.whatsapp,
                    p.email,
                    p.status,
                    p.created_at.isoformat(),
                ]
            )

        return response


class ProductManageImportCSVView(ManageAccessMixin, FormView):
    template_name = "products/product_import.html"
    form_class = ProductImportForm
    success_url = reverse_lazy("products_manage:products_manage_list")

    def form_valid(self, form):
        file = form.cleaned_data["file"]
        reader = csv.DictReader(TextIOWrapper(file.file, encoding="utf-8"))
        created = 0
        updated = 0

        for row in reader:
            name = (row.get("name") or "").strip()
            if not name:
                continue

            category_name = (row.get("category") or "General").strip() or "General"
            category, _ = Category.objects.get_or_create(name=category_name)

            defaults = {
                "description": (row.get("description") or "").strip(),
                "category": category,
                "price": (row.get("price") or "0").strip() or "0",
                "country": (row.get("country") or "Cameroun").strip() or "Cameroun",
                "city": (row.get("city") or "").strip(),
                "gallery_images": (row.get("gallery_images") or "").strip(),
                "video_url": (row.get("video_url") or "").strip(),
                "phone": (row.get("phone") or "").strip(),
                "whatsapp": (row.get("whatsapp") or "").strip(),
                "email": (row.get("email") or "").strip(),
                "status": (row.get("status") or Product.STATUS_AVAILABLE).strip() or Product.STATUS_AVAILABLE,
            }

            product, was_created = Product.objects.update_or_create(name=name, defaults=defaults)

            image_value = (row.get("image") or "").strip()
            if image_value:
                product.image = image_value
                product.save(update_fields=["image"])

            if was_created:
                created += 1
            else:
                updated += 1

        messages.success(self.request, f"Import termine. Crees: {created}, mis a jour: {updated}.")
        return super().form_valid(form)
