import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../models/product.dart';
import '../state/shop_state.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product, required this.shopState});

  final Product product;
  final ShopState shopState;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final PageController _pageController;
  int _index = 0;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.product.videoUrl.isNotEmpty) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.product.videoUrl))
        ..initialize().then((_) {
          if (mounted) setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.product.media;
    final price = NumberFormat.decimalPattern('fr_FR').format(widget.product.price);
    final availability = widget.product.isAvailable ? 'Disponible' : 'Rupture';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
        children: [
          SizedBox(
            height: 320,
            child: media.isEmpty
                ? const Card(child: Center(child: Text('No image')))
                : Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: media.length,
                        onPageChanged: (v) => setState(() => _index = v),
                        itemBuilder: (_, i) => Card(
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(media[i], fit: BoxFit.cover),
                        ),
                      ),
                      if (media.length > 1)
                        Positioned(
                          bottom: 14,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              media.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: i == _index ? 18 : 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: i == _index ? Colors.white : Colors.white54,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          if (_videoController != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: _videoController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_videoController!),
                            IconButton(
                              iconSize: 46,
                              onPressed: () {
                                if (_videoController!.value.isPlaying) {
                                  _videoController!.pause();
                                } else {
                                  _videoController!.play();
                                }
                                setState(() {});
                              },
                              icon: Icon(
                                _videoController!.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      )
                    : const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.category, style: const TextStyle(fontSize: 12, color: Color(0xFF4B64B0))),
                  const SizedBox(height: 6),
                  Text(widget.product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('$price XAF', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(widget.product.description.isEmpty ? 'Aucune description.' : widget.product.description),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      _DetailChip(icon: Icons.public, label: widget.product.country),
                      _DetailChip(
                        icon: Icons.location_on_outlined,
                        label: widget.product.city.isEmpty ? 'Ville non renseignee' : widget.product.city,
                      ),
                      _DetailChip(icon: Icons.inventory_2_outlined, label: availability),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (widget.product.phone.isNotEmpty ||
                      widget.product.whatsapp.isNotEmpty ||
                      widget.product.email.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Contacts', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        if (widget.product.phone.isNotEmpty)
                          Text('Tel: ${widget.product.phone}', style: const TextStyle(color: Color(0xFF65708B))),
                        if (widget.product.whatsapp.isNotEmpty)
                          Text('WhatsApp: ${widget.product.whatsapp}', style: const TextStyle(color: Color(0xFF65708B))),
                        if (widget.product.email.isNotEmpty)
                          Text('Email: ${widget.product.email}', style: const TextStyle(color: Color(0xFF65708B))),
                        const SizedBox(height: 12),
                      ],
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: widget.product.isAvailable
                          ? () async {
                              await widget.shopState.addToCart(widget.product);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Produit ajoute au chariot')),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.shopping_cart_checkout_rounded),
                      label: const Text('Ajouter au chariot'),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4B64B0)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
