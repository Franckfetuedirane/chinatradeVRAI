class Product {
  final int id;
  final String name;
  final String category;
  final String categorySlug;
  final String description;
  final double price;
  final String country;
  final String city;
  final String image;
  final List<String> galleryImages;
  final String videoUrl;
  final String phone;
  final String whatsapp;
  final String email;
  final String status;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.categorySlug,
    required this.description,
    required this.price,
    required this.country,
    required this.city,
    required this.image,
    required this.galleryImages,
    required this.videoUrl,
    required this.phone,
    required this.whatsapp,
    required this.email,
    required this.status,
    required this.createdAt,
  });

  bool get isAvailable => status == 'available';

  List<String> get media {
    final merged = <String>[];
    if (image.isNotEmpty) merged.add(image);
    for (final g in galleryImages) {
      if (g.isNotEmpty && !merged.contains(g)) merged.add(g);
    }
    return merged;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final galleryRaw = (json['gallery_images'] is List) ? json['gallery_images'] as List : const [];
    final gallery = galleryRaw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();

    final priceRaw = json['price'];
    final price = priceRaw is num ? priceRaw.toDouble() : double.tryParse(priceRaw?.toString() ?? '0') ?? 0;

    return Product(
      id: json['id'] as int,
      name: (json['name'] ?? '').toString(),
      category: (json['category'] ?? 'General').toString(),
      categorySlug: (json['category_slug'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: price,
      country: (json['country'] ?? 'Cameroun').toString(),
      city: (json['city'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      galleryImages: gallery,
      videoUrl: (json['video_url'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      whatsapp: (json['whatsapp'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'category_slug': categorySlug,
        'description': description,
        'price': price,
        'country': country,
        'city': city,
        'image': image,
        'gallery_images': galleryImages,
        'video_url': videoUrl,
        'phone': phone,
        'whatsapp': whatsapp,
        'email': email,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
      };
}
