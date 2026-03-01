from django import forms
from django.conf import settings
from .models import Product


class ProductForm(forms.ModelForm):
    class Meta:
        model = Product
        fields = ["name", "description", "image", "phone", "whatsapp", "email", "status"]
        widgets = {
            "description": forms.Textarea(attrs={"rows": 3}),
        }

    def clean(self):
        cleaned_data = super().clean()
        image = cleaned_data.get("image")
        cloudinary_enabled = getattr(settings, "CLOUDINARY_ENABLED", False)
        if image and not cloudinary_enabled:
            raise forms.ValidationError(
                "Upload image indisponible: configurez Cloudinary "
                "(CLOUDINARY_URL ou CLOUDINARY_CLOUD_NAME/API_KEY/API_SECRET)."
            )
        return cleaned_data
