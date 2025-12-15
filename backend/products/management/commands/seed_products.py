from django.core.management.base import BaseCommand
from django.core.files import File
from django.conf import settings
from pathlib import Path
import json
import csv
from products.models import Product


class Command(BaseCommand):
    help = (
        "Seed or update products from files in MEDIA_ROOT/products. "
        "Supports optional products.json or products.csv for metadata."
    )

    def handle(self, *args, **options):
        media_root = Path(settings.MEDIA_ROOT)
        products_dir = media_root / "products"

        # Load available image files
        image_files = []
        if products_dir.exists() and products_dir.is_dir():
            for p in products_dir.iterdir():
                if p.is_file():
                    image_files.append(p)

        # Load metadata if present
        meta = []
        json_file = products_dir / "products.json"
        csv_file = products_dir / "products.csv"

        if json_file.exists():
            try:
                meta = json.loads(json_file.read_text(encoding="utf-8"))
            except Exception as e:
                self.stdout.write(self.style.WARNING(f"Failed to parse products.json: {e}"))
                meta = []
        elif csv_file.exists():
            try:
                with open(csv_file, newline='', encoding='utf-8') as fh:
                    reader = csv.DictReader(fh)
                    for row in reader:
                        meta.append(row)
            except Exception as e:
                self.stdout.write(self.style.WARNING(f"Failed to parse products.csv: {e}"))
                meta = []

        # Helper to normalize names
        def norm_name(s):
            return " ".join(s.replace('_', ' ').replace('-', ' ').split()).strip()

        # Map meta by image filename or name
        meta_by_image = {}
        meta_by_name = {}
        for item in meta:
            # accept keys: name, description, phone, whatsapp, email, status, image or image_filename
            image_key = item.get("image") or item.get("image_filename")
            if image_key:
                meta_by_image[image_key] = item
            if item.get("name"):
                meta_by_name[norm_name(item["name"]).lower()] = item

        created = 0
        updated = 0

        # Process metadata-first: ensure products described in meta exist
        for item in meta:
            name = norm_name(item.get("name") or item.get("title") or "").strip()
            if not name:
                # try derive from image filename
                image_key = item.get("image") or item.get("image_filename")
                if image_key:
                    name = Path(image_key).stem
                else:
                    continue

            defaults = {
                "description": item.get("description", ""),
                "phone": item.get("phone", ""),
                "whatsapp": item.get("whatsapp", ""),
                "email": item.get("email", ""),
                "status": item.get("status", Product.STATUS_AVAILABLE),
            }

            prod, created_flag = Product.objects.update_or_create(
                name=name, defaults=defaults
            )

            # attach image if present in media
            image_key = item.get("image") or item.get("image_filename")
            if image_key:
                img_path = products_dir / image_key
                if img_path.exists():
                    # Avoid re-saving if the product already uses this exact file
                    dest_name = f"products/{img_path.name}"
                    if prod.image and prod.image.name == dest_name:
                        # already attached, skip
                        pass
                    else:
                        with open(img_path, "rb") as f:
                            prod.image.save(img_path.name, File(f), save=True)

            if created_flag:
                created += 1
            else:
                updated += 1

        # Next: process image files not referenced in meta
        referenced_images = set(meta_by_image.keys())
        for img in image_files:
            if img.name in referenced_images:
                continue
            # derive product name from filename
            name = norm_name(img.stem).title()

            # Avoid duplicate by name
            prod, created_flag = Product.objects.get_or_create(
                name=name,
                defaults={
                    "description": "",
                    "phone": "",
                    "whatsapp": "",
                    "email": "",
                    "status": Product.STATUS_AVAILABLE,
                },
            )

            # If product exists but has no image OR image is different, attach only if needed
            dest_name = f"products/{img.name}"
            if not prod.image or prod.image.name == "" or prod.image.name != dest_name:
                # if the source file is already at the destination path, skip copying to avoid duplicates
                src_path = img.resolve()
                dest_path = (media_root / dest_name).resolve()
                if src_path == dest_path:
                    # file already in correct location and storage refers to it; just ensure prod.image points to it
                    prod.image.name = dest_name
                    prod.save()
                else:
                    with open(img, "rb") as f:
                        prod.image.save(img.name, File(f), save=True)

            if created_flag:
                created += 1
            else:
                updated += 1

        self.stdout.write(self.style.SUCCESS(f"Seed complete — created: {created}, updated: {updated}"))
        # If no metadata file exists, generate a default products.json based on current products
        if not json_file.exists():
            out = []
            for p in Product.objects.all():
                img_filename = Path(p.image.name).name if p.image else ""
                out.append({
                    "name": p.name,
                    "description": p.description or f"Description for {p.name}",
                    "phone": p.phone or "+33123456789",
                    "whatsapp": p.whatsapp or p.phone or "33123456789",
                    "email": p.email or "sales@chinatrademaster.com",
                    "status": p.status,
                    "image": img_filename,
                })
            try:
                json_file.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
                self.stdout.write(self.style.SUCCESS(f"Generated default metadata at {json_file}"))
            except Exception as e:
                self.stdout.write(self.style.WARNING(f"Failed to write products.json: {e}"))
