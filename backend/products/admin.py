from django.contrib import admin
from django.utils.html import format_html
from .models import Category, Product

admin.site.site_header = "FOESA Admin"
admin.site.site_title = "FOESA"
admin.site.index_title = "Gestion des produits"


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ("image_tag", "name", "category", "price", "country", "city", "status", "phone", "email", "created_at")
    list_filter = ("status", "category", "country", "city")
    search_fields = ("name", "category__name", "description", "country", "city", "phone", "whatsapp", "email")
    actions = ["mark_available", "mark_out_of_stock"]

    def image_tag(self, obj):
        try:
            url = obj.get_image_url()
        except Exception:
            url = None
        if url:
            return format_html(
                '<img src="{}" style="width:48px;height:48px;object-fit:cover;border-radius:4px;" />',
                url,
            )
        return "-"

    image_tag.short_description = "Image"

    def mark_available(self, request, queryset):
        queryset.update(status=Product.STATUS_AVAILABLE)

    mark_available.short_description = "Mark selected products as Available"

    def mark_out_of_stock(self, request, queryset):
        queryset.update(status=Product.STATUS_OUT)

    mark_out_of_stock.short_description = "Mark selected products as Out of Stock"


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ("name", "slug", "created_at")
    search_fields = ("name", "slug")
