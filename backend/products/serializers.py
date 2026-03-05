from rest_framework import serializers
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
        url = obj.get_image_url()
        if not url:
            return ""

        request = self.context.get("request")
        if request and url.startswith("/"):
            return request.build_absolute_uri(url)
        return url

    def get_gallery_images(self, obj):
        request = self.context.get("request")
        results = []
        for url in obj.get_gallery_urls():
            if request and url.startswith("/"):
                results.append(request.build_absolute_uri(url))
            else:
                results.append(url)
        return results
