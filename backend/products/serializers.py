from rest_framework import serializers
from .models import Product
from django.conf import settings

class ProductSerializer(serializers.ModelSerializer):
    image = serializers.SerializerMethodField()  # <-- ajoute ça

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
        if not obj.image:
            return ""
        try:
            url = obj.image.url
        except Exception:
            # fallback when Cloudinary not configured or url generation fails
            try:
                name = getattr(obj.image, "name", "")
                if not name:
                    return ""
                return str(settings.MEDIA_URL).rstrip("/") + "/" + name.lstrip("/")
            except Exception:
                return ""
        # return absolute URL if request in context, otherwise raw url
        request = self.context.get("request")
        if request:
            return request.build_absolute_uri(url)
        return url
