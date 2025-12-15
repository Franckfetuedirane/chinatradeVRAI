from django import forms
from .models import Product


class ProductForm(forms.ModelForm):
    class Meta:
        model = Product
        fields = ["name", "description", "image", "phone", "whatsapp", "email", "status"]
        widgets = {
            "description": forms.Textarea(attrs={"rows": 3}),
        }
