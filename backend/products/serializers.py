from rest_framework import serializers
from .models import Product

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
        if obj.image:
            return obj.image.url  # <-- génère l'URL complète Cloudinary
        return None
