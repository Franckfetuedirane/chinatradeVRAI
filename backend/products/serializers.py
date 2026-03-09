from rest_framework import serializers
from django.conf import settings
from .models import Product


class ProductSerializer(serializers.ModelSerializer):
    image = serializers.SerializerMethodField()
    gallery_images = serializers.SerializerMethodField()
    category = serializers.CharField(source="category.name", read_only=True)
    category_slug = serializers.CharField(source="category.slug", read_only=True)

    class Meta:
        model = Product
        fields = [
            "id",
            "name",
            "category",
            "category_slug",
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

    def get_image(self, obj):
        return self._to_public_url(obj.get_image_url())

    def get_gallery_images(self, obj):
        results = []
        for url in obj.get_gallery_urls():
            resolved = self._to_public_url(url)
            if resolved:
                results.append(resolved)
        return results

    def _to_public_url(self, url: str) -> str:
        if not url:
            return ""

        is_absolute = url.startswith("http://") or url.startswith("https://")
        normalized = url if is_absolute else (url if url.startswith("/") else f"/{url.lstrip('/')}")

        if not is_absolute:
            public_origin = getattr(settings, "API_PUBLIC_ORIGIN", "")
            if public_origin:
                normalized = f"{public_origin}{normalized}"
            else:
                request = self.context.get("request")
                if request:
                    normalized = request.build_absolute_uri(normalized)

        if not settings.DEBUG and normalized.startswith("http://"):
            normalized = "https://" + normalized[len("http://") :]

        return normalized
