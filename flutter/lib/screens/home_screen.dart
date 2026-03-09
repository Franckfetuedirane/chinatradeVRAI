import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../screens/cart_screen.dart';
import '../screens/catalog_screen.dart';
import '../state/shop_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.shopState});

  final ShopState shopState;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      CatalogScreen(shopState: widget.shopState),
      CartScreen(shopState: widget.shopState),
    ];

    return AnimatedBuilder(
      animation: widget.shopState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    AppConfig.logoUrl,
                    width: 34,
                    height: 34,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.storefront, size: 30),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('FOESA Mobile'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: widget.shopState.refreshProducts,
                tooltip: 'Rafraichir',
              )
            ],
          ),
          body: pages[_index],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (v) => setState(() => _index = v),
            destinations: [
              const NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Catalogue'),
              NavigationDestination(
                icon: Badge.count(count: widget.shopState.cartCount, child: const Icon(Icons.shopping_cart_rounded)),
                label: 'Chariot',
              ),
            ],
          ),
        );
      },
    );
  }
}
