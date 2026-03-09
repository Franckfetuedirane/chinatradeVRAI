import 'package:flutter/material.dart';

import '../screens/product_detail_screen.dart';
import '../state/shop_state.dart';
import '../widgets/product_card.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key, required this.shopState});

  final ShopState shopState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shopState,
      builder: (context, _) {
        if (shopState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (shopState.error.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(shopState.error, textAlign: TextAlign.center),
            ),
          );
        }

        final products = shopState.filteredProducts;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Wrap(
                runSpacing: 10,
                spacing: 10,
                children: [
                  SizedBox(
                    width: 330,
                    child: TextField(
                      onChanged: shopState.setSearch,
                      decoration: const InputDecoration(
                        hintText: 'Rechercher un produit...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 210,
                    child: DropdownButtonFormField<String>(
                      value: shopState.selectedCategory.isEmpty ? null : shopState.selectedCategory,
                      decoration: const InputDecoration(labelText: 'Categorie'),
                      items: [
                        const DropdownMenuItem(value: '', child: Text('Toutes')),
                        ...shopState.categories.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                      ],
                      onChanged: (v) => shopState.setCategory(v ?? ''),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      value: shopState.selectedCountry,
                      decoration: const InputDecoration(labelText: 'Pays'),
                      items: shopState.countries.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (v) => shopState.setCountry(v ?? 'Cameroun'),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: DropdownButtonFormField<String>(
                      value: shopState.selectedCity.isEmpty ? null : shopState.selectedCity,
                      decoration: const InputDecoration(labelText: 'Ville'),
                      items: [
                        const DropdownMenuItem(value: '', child: Text('Toutes')),
                        ...shopState.cities.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                      ],
                      onChanged: (v) => shopState.setCity(v ?? ''),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text('Aucun produit trouve.'))
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.66,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: products.length,
                      itemBuilder: (_, i) {
                        final p = products[i];
                        return ProductCard(
                          product: p,
                          onOpen: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(product: p, shopState: shopState),
                              ),
                            );
                          },
                          onAdd: () async {
                            await shopState.addToCart(p);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Produit ajoute au chariot')));
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
