import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _CatalogHeader(shopState: shopState, total: products.length)),
            if (products.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.search_off_rounded, size: 42, color: Color(0xFF65708B)),
                            SizedBox(height: 10),
                            Text('Aucun produit trouve.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.67,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Produit ajoute au chariot')),
                          );
                        },
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({required this.shopState, required this.total});

  final ShopState shopState;
  final int total;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('fr_FR');
    final bounds = shopState.priceBounds;
    final range = shopState.priceRange;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Catalogue Production',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$total produits disponibles',
                    style: const TextStyle(color: Color(0xFF65708B)),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: shopState.setSearch,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un produit...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () => _openFilters(context),
                          icon: const Icon(Icons.tune_rounded),
                          label: const Text('Filtres'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<SortOption>(
                          value: shopState.sortOption,
                          decoration: const InputDecoration(labelText: 'Tri'),
                          items: SortOption.values
                              .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                              .toList(),
                          onChanged: (v) => shopState.setSortOption(v ?? SortOption.newest),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: shopState.availabilityFilter.label,
                onClear: shopState.availabilityFilter == AvailabilityFilter.available
                    ? null
                    : () => shopState.setAvailabilityFilter(AvailabilityFilter.available),
              ),
              if (shopState.selectedCategory.isNotEmpty)
                _FilterChip(
                  label: shopState.selectedCategory,
                  onClear: () => shopState.setCategory(''),
                ),
              if (shopState.selectedCountry.isNotEmpty)
                _FilterChip(
                  label: shopState.selectedCountry,
                  onClear: () => shopState.setCountry(''),
                ),
              if (shopState.selectedCity.isNotEmpty)
                _FilterChip(
                  label: shopState.selectedCity,
                  onClear: () => shopState.setCity(''),
                ),
              if (bounds.start != bounds.end &&
                  (range.start > bounds.start || range.end < bounds.end))
                _FilterChip(
                  label: '${formatter.format(range.start)} - ${formatter.format(range.end)} XAF',
                  onClear: () => shopState.setPriceRange(bounds),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _openFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return AnimatedBuilder(
          animation: shopState,
          builder: (context, _) {
            final bounds = shopState.priceBounds;
            final range = shopState.priceRange;
            final formatter = NumberFormat.decimalPattern('fr_FR');

            return Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filtres avances', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: shopState.selectedCategory.isEmpty ? null : shopState.selectedCategory,
                      decoration: const InputDecoration(labelText: 'Categorie'),
                      items: [
                        const DropdownMenuItem(value: '', child: Text('Toutes')),
                        ...shopState.categories.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                      ],
                      onChanged: (v) => shopState.setCategory(v ?? ''),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: shopState.selectedCountry,
                      decoration: const InputDecoration(labelText: 'Pays'),
                      items: [
                        const DropdownMenuItem(value: '', child: Text('Tous')),
                        ...shopState.countries.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                      ],
                      onChanged: (v) => shopState.setCountry(v ?? ''),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: shopState.selectedCity.isEmpty ? null : shopState.selectedCity,
                      decoration: const InputDecoration(labelText: 'Ville'),
                      items: [
                        const DropdownMenuItem(value: '', child: Text('Toutes')),
                        ...shopState.cities.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                      ],
                      onChanged: (v) => shopState.setCity(v ?? ''),
                    ),
                    const SizedBox(height: 18),
                    const Text('Disponibilite', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: AvailabilityFilter.values
                          .map(
                            (e) => ChoiceChip(
                              label: Text(e.label),
                              selected: shopState.availabilityFilter == e,
                              onSelected: (_) => shopState.setAvailabilityFilter(e),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    const Text('Fourchette de prix', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(
                      bounds.start == bounds.end
                          ? 'Aucun prix disponible'
                          : '${formatter.format(range.start)} - ${formatter.format(range.end)} XAF',
                      style: const TextStyle(color: Color(0xFF65708B)),
                    ),
                    if (bounds.start != bounds.end)
                      RangeSlider(
                        values: range,
                        min: bounds.start,
                        max: bounds.end,
                        onChanged: shopState.setPriceRange,
                      ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<SortOption>(
                      value: shopState.sortOption,
                      decoration: const InputDecoration(labelText: 'Tri principal'),
                      items: SortOption.values
                          .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                          .toList(),
                      onChanged: (v) => shopState.setSortOption(v ?? SortOption.newest),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: shopState.resetFilters,
                            child: const Text('Reinitialiser'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Appliquer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.onClear});

  final String label;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      deleteIcon: onClear == null ? null : const Icon(Icons.close, size: 16),
      onDeleted: onClear,
      backgroundColor: const Color(0xFFF0F4FF),
      side: const BorderSide(color: Color(0xFFE0E6F3)),
    );
  }
}
