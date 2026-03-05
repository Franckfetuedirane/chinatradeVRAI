from rest_framework import serializers
from .models import Product


class ProductSerializer(serializers.ModelSerializer):
    image = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = [
            "id",
            "name",
            "description",
            "image",
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
