import 'package:flutter/material.dart';

import '../state/shop_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.shopState});

  final ShopState shopState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shopState,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Livraison', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: shopState.shippingCountry,
                        decoration: const InputDecoration(labelText: 'Pays'),
                        items: shopState.countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => shopState.setShippingCountry(v ?? 'Cameroun'),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: shopState.shippingCity.isEmpty ? null : shopState.shippingCity,
                        decoration: const InputDecoration(labelText: 'Ville'),
                        items: shopState.shippingCities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => shopState.setShippingCity(v ?? ''),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: shopState.cart.isEmpty
                    ? const Center(child: Text('Votre chariot est vide.'))
                    : ListView.separated(
                        itemCount: shopState.cart.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final item = shopState.cart[i];
                          return Card(
                            child: ListTile(
                              title: Text(item.product.name),
                              subtitle: Text('${item.product.price.toStringAsFixed(0)} XAF x ${item.quantity}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => shopState.updateQuantity(item.product.id, item.quantity - 1),
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    onPressed: () => shopState.updateQuantity(item.product.id, item.quantity + 1),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                  IconButton(
                                    onPressed: () => shopState.removeFromCart(item.product.id),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      Text('${shopState.cartTotal.toStringAsFixed(0)} XAF', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
