import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          SizedBox(
            height: 320,
            child: media.isEmpty
                ? const Card(child: Center(child: Text('No image')))
                : PageView.builder(
                    controller: _pageController,
                    itemCount: media.length,
                    onPageChanged: (v) => setState(() => _index = v),
                    itemBuilder: (_, i) => Card(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(media[i], fit: BoxFit.cover),
                      ),
                    ),
                  ),
          ),
          if (media.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                media.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _index ? Theme.of(context).colorScheme.primary : Colors.black26,
                  ),
                ),
              ),
            ),
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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.category, style: const TextStyle(fontSize: 12, color: Colors.indigo)),
                  const SizedBox(height: 6),
                  Text(widget.product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text('${widget.product.price.toStringAsFixed(0)} XAF', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(widget.product.description.isEmpty ? 'Aucune description.' : widget.product.description),
                  const SizedBox(height: 12),
                  Text('Pays: ${widget.product.country}'),
                  Text('Ville: ${widget.product.city.isEmpty ? 'Non renseignee' : widget.product.city}'),
                  Text('Statut: ${widget.product.isAvailable ? 'Disponible' : 'Rupture'}'),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        await widget.shopState.addToCart(widget.product);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Produit ajoute au chariot')),
                        );
                      },
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
