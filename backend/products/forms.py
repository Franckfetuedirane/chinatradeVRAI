from django import forms
from .models import Product


class ProductForm(forms.ModelForm):
    class Meta:
        model = Product
        fields = [
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
        ]
        widgets = {
            "description": forms.Textarea(attrs={"rows": 5}),
            "gallery_images": forms.Textarea(attrs={"rows": 4, "placeholder": "URL/chemin image 1\nURL/chemin image 2"}),
        }


class ProductBulkActionForm(forms.Form):
    ACTION_AVAILABLE = "mark_available"
    ACTION_OUT = "mark_out"
    ACTION_DELETE = "delete"

    ACTION_CHOICES = (
        (ACTION_AVAILABLE, "Mark selected as Available"),
        (ACTION_OUT, "Mark selected as Out of stock"),
        (ACTION_DELETE, "Delete selected"),
    )

    action = forms.ChoiceField(choices=ACTION_CHOICES)


class ProductImportForm(forms.Form):
    file = forms.FileField(
        help_text="CSV UTF-8 with headers: name, description, price, country, city, image, gallery_images, video_url, phone, whatsapp, email, status"
    )
