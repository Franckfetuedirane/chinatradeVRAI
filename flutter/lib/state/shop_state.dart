import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class ShopState extends ChangeNotifier {
  ShopState({ApiService? api, LocalStorageService? storage})
      : _api = api ?? const ApiService(),
        _storage = storage ?? LocalStorageService();

  final ApiService _api;
  final LocalStorageService _storage;

  bool _loading = true;
  String _error = '';

  final List<Product> _products = [];
  final List<CartItem> _cart = [];

  String search = '';
  String selectedCategory = '';
  String selectedCountry = 'Cameroun';
  String selectedCity = '';

  String shippingCountry = 'Cameroun';
  String shippingCity = '';

  bool get isLoading => _loading;
  String get error => _error;

  List<Product> get products => List.unmodifiable(_products);
  List<CartItem> get cart => List.unmodifiable(_cart);

  int get cartCount => _cart.fold(0, (a, b) => a + b.quantity);
  double get cartTotal => _cart.fold(0, (a, b) => a + b.total);

  List<String> get categories {
    final set = _products.map((e) => e.category).where((e) => e.isNotEmpty).toSet();
    final list = set.toList()..sort();
    return list;
  }

  List<String> get countries {
    final set = {'Cameroun', ..._products.map((e) => e.country).where((e) => e.isNotEmpty)};
    final list = set.toList()..sort();
    return list;
  }

  List<String> get cities {
    final preset = AppConfig.countryCities[selectedCountry] ?? const <String>[];
    final dynamic = _products
        .where((p) => selectedCountry.isEmpty || p.country.toLowerCase() == selectedCountry.toLowerCase())
        .map((e) => e.city)
        .where((e) => e.isNotEmpty)
        .toSet();
    final merged = {...preset, ...dynamic}.toList()..sort();
    return merged;
  }

  List<String> get shippingCities => AppConfig.countryCities[shippingCountry] ?? const [];

  List<Product> get filteredProducts {
    final q = search.trim().toLowerCase();
    return _products.where((p) {
      final okSearch = q.isEmpty ||
          ('${p.name} ${p.description} ${p.country} ${p.city} ${p.category}'.toLowerCase().contains(q));
      final okCategory = selectedCategory.isEmpty || p.category.toLowerCase() == selectedCategory.toLowerCase();
      final okCountry = selectedCountry.isEmpty || p.country.toLowerCase() == selectedCountry.toLowerCase();
      final okCity = selectedCity.isEmpty || p.city.toLowerCase().contains(selectedCity.toLowerCase());
      return okSearch && okCategory && okCountry && okCity;
    }).toList();
  }

  Future<void> initialize() async {
    await _loadCart();
    await refreshProducts();
  }

  Future<void> refreshProducts() async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      final list = await _api.fetchProducts();
      _products
        ..clear()
        ..addAll(list);
    } catch (e) {
      _error = "Impossible de charger les produits depuis l'API production.";
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCart() async {
    final saved = await _storage.readCart();
    _cart
      ..clear()
      ..addAll(saved);
  }

  Future<void> _persistCart() async {
    await _storage.writeCart(_cart);
  }

  void setSearch(String value) {
    search = value;
    notifyListeners();
  }

  void setCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  void setCountry(String value) {
    selectedCountry = value;
    selectedCity = '';
    notifyListeners();
  }

  void setCity(String value) {
    selectedCity = value;
    notifyListeners();
  }

  void setShippingCountry(String value) {
    shippingCountry = value;
    shippingCity = '';
    notifyListeners();
  }

  void setShippingCity(String value) {
    shippingCity = value;
    notifyListeners();
  }

  Future<void> addToCart(Product product) async {
    final index = _cart.indexWhere((e) => e.product.id == product.id);
    if (index >= 0) {
      _cart[index].quantity += 1;
    } else {
      _cart.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
    await _persistCart();
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    final index = _cart.indexWhere((e) => e.product.id == productId);
    if (index < 0) return;

    if (quantity <= 0) {
      _cart.removeAt(index);
    } else {
      _cart[index].quantity = quantity;
    }

    notifyListeners();
    await _persistCart();
  }

  Future<void> removeFromCart(int productId) async {
    _cart.removeWhere((e) => e.product.id == productId);
    notifyListeners();
    await _persistCart();
  }
}
