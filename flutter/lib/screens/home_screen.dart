import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../screens/cart_screen.dart';
import '../screens/catalog_screen.dart';
import '../state/shop_state.dart';
import '../widgets/app_background.dart';

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
        final user = widget.shopState.user;
        final userLabel = user?.displayName ?? 'Compte';

        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    AppConfig.logoAsset,
                    width: 36,
                    height: 36,
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
              ),
              PopupMenuButton<String>(
                tooltip: 'Compte',
                onSelected: (value) async {
                  if (value == 'logout') {
                    await widget.shopState.logout();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    enabled: false,
                    child: Text(userLabel),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Se deconnecter'),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFEAF0FF),
                    child: Text(
                      userLabel.isNotEmpty ? userLabel[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Color(0xFF0B4EDB), fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: AppBackground(child: pages[_index]),
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
