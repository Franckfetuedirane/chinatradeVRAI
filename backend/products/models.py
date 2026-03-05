from django.db import models
from cloudinary.models import CloudinaryField
from django.conf import settings
import os

class Product(models.Model):
    STATUS_AVAILABLE = "available"
    STATUS_OUT = "out"

    STATUS_CHOICES = [
        (STATUS_AVAILABLE, "Available"),
        (STATUS_OUT, "Out of stock"),
    ]

    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    image = CloudinaryField("image", blank=True, null=True)
    phone = models.CharField(max_length=50, blank=True)
    whatsapp = models.CharField(max_length=50, blank=True)
    email = models.EmailField(blank=True)
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default=STATUS_AVAILABLE
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return self.name

    def get_image_url(self):
        """
        Safe image URL getter: tries to use storage-generated URL (Cloudinary),
        falls back to local MEDIA_URL + file name when url generation raises.
        """
        if not self.image:
            return ""
        try:
            return self.image.url
        except Exception:
            # CloudinaryField values are often stored as public_id strings.
            # When SDK URL generation fails locally, build a direct Cloudinary URL.
            raw_value = str(self.image).strip()
            name = (getattr(self.image, "name", "") or raw_value).strip()
            if not name:
                return ""
            if name.startswith("http://") or name.startswith("https://"):
                return name

            cloud_name = getattr(settings, "CLOUDINARY_CLOUD_NAME", "") or os.environ.get("CLOUDINARY_CLOUD_NAME", "")
            if cloud_name and not name.startswith("/"):
                return f"https://res.cloudinary.com/{cloud_name}/image/upload/{name.lstrip('/')}"

            return str(settings.MEDIA_URL).rstrip("/") + "/" + name.lstrip("/")
