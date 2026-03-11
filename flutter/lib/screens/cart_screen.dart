import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../state/shop_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.shopState});

  final ShopState shopState;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('fr_FR');
    return AnimatedBuilder(
      animation: shopState,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Livraison', style: TextStyle(fontWeight: FontWeight.w700)),
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
                          final total = formatter.format(item.total);
                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              title: Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(
                                '${formatter.format(item.product.price)} XAF x ${item.quantity}',
                                style: const TextStyle(color: Color(0xFF65708B)),
                              ),
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
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(
                        '${formatter.format(shopState.cartTotal)} XAF',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
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
