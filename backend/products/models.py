from django.db import models
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
    image = models.ImageField(upload_to="products/", blank=True, null=True)
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
        Return a usable image URL in both local-file and Cloudinary-legacy modes.
        """
        if not self.image:
            return ""

        raw_value = str(self.image).strip()
        if raw_value.startswith("http://") or raw_value.startswith("https://"):
            return raw_value

        cloud_name = getattr(settings, "CLOUDINARY_CLOUD_NAME", "") or os.environ.get("CLOUDINARY_CLOUD_NAME", "")
        # Legacy data in DB can be a Cloudinary public path like:
        # image/upload/v1772707028/xxxx.png
        if cloud_name and (raw_value.startswith("image/upload/") or "/upload/" in raw_value):
            return f"https://res.cloudinary.com/{cloud_name}/{raw_value.lstrip('/')}"

        try:
            return self.image.url
        except Exception:
            # Fallback for unexpected storage errors.
            name = (getattr(self.image, "name", "") or raw_value).strip()
            if not name:
                return ""

            if cloud_name and not name.startswith("/"):
                return f"https://res.cloudinary.com/{cloud_name}/image/upload/{name.lstrip('/')}"

            return str(settings.MEDIA_URL).rstrip("/") + "/" + name.lstrip("/")
