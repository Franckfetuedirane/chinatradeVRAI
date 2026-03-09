from django.db import models
from django.conf import settings
from django.utils.text import slugify
import os
from urllib.parse import urlparse

class Category(models.Model):
    name = models.CharField(max_length=120, unique=True)
    slug = models.SlugField(max_length=140, unique=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["name"]
        verbose_name_plural = "categories"

    def save(self, *args, **kwargs):
        if not self.slug:
            base = slugify(self.name) or "category"
            candidate = base
            idx = 2
            while Category.objects.exclude(pk=self.pk).filter(slug=candidate).exists():
                candidate = f"{base}-{idx}"
                idx += 1
            self.slug = candidate
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name


def get_default_category_id():
    category, _ = Category.objects.get_or_create(name="General")
    return category.id


class Product(models.Model):
    STATUS_AVAILABLE = "available"
    STATUS_OUT = "out"

    STATUS_CHOICES = [
        (STATUS_AVAILABLE, "Available"),
        (STATUS_OUT, "Out of stock"),
    ]

    name = models.CharField(max_length=200)
    category = models.ForeignKey(
        Category,
        on_delete=models.PROTECT,
        related_name="products",
        default=get_default_category_id,
    )
    description = models.TextField(blank=True)
    price = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    country = models.CharField(max_length=120, default="Cameroun")
    city = models.CharField(max_length=120, blank=True)
    image = models.ImageField(upload_to="products/", blank=True, null=True)
    gallery_images = models.TextField(
        blank=True,
        help_text="Liste d'URLs ou chemins d'images separes par virgule ou retour ligne.",
    )
    video_url = models.URLField(blank=True)
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

    def _get_cloudinary_cloud_name(self) -> str:
        cloud_name = (getattr(settings, "CLOUDINARY_CLOUD_NAME", "") or os.environ.get("CLOUDINARY_CLOUD_NAME", "")).strip()
        if cloud_name:
            return cloud_name

        cloudinary_url = (getattr(settings, "CLOUDINARY_URL", "") or os.environ.get("CLOUDINARY_URL", "")).strip()
        if cloudinary_url:
            try:
                parsed = urlparse(cloudinary_url)
                # CLOUDINARY_URL format: cloudinary://api_key:api_secret@cloud_name
                return (parsed.hostname or "").strip()
            except Exception:
                return ""
        return ""

    def _as_cloudinary_url(self, raw_value: str) -> str:
        cloud_name = self._get_cloudinary_cloud_name()
        if not cloud_name:
            return ""

        normalized = (raw_value or "").strip().replace("\\", "/")
        if not normalized:
            return ""

        marker = "image/upload/"
        idx = normalized.find(marker)
        if idx == -1:
            return ""

        upload_path = normalized[idx:]
        return f"https://res.cloudinary.com/{cloud_name}/{upload_path}"

    def _resolve_media_url(self, value: str) -> str:
        raw_value = (value or "").strip().replace("\\", "/")
        if not raw_value:
            return ""

        if raw_value.startswith("http://") or raw_value.startswith("https://"):
            cloud_url = self._as_cloudinary_url(raw_value)
            if cloud_url:
                return cloud_url
            return raw_value

        if raw_value.startswith("media/"):
            raw_value = raw_value[len("media/") :]
        if raw_value.startswith("/media/"):
            raw_value = raw_value[len("/media/") :]

        cloud_url = self._as_cloudinary_url(raw_value)
        if cloud_url:
            return cloud_url

        return str(settings.MEDIA_URL).rstrip("/") + "/" + raw_value.lstrip("/")

    def get_image_url(self):
        if not self.image:
            return ""

        fallback = str(getattr(self.image, "name", "") or self.image)
        try:
            return self._resolve_media_url(self.image.url)
        except Exception:
            return self._resolve_media_url(fallback)

    def get_gallery_urls(self):
        urls = []
        primary = self.get_image_url()
        if primary:
            urls.append(primary)

        raw_items = self.gallery_images.replace("\r", "\n").replace(",", "\n").split("\n")
        for item in raw_items:
            resolved = self._resolve_media_url(item)
            if resolved and resolved not in urls:
                urls.append(resolved)
        return urls
