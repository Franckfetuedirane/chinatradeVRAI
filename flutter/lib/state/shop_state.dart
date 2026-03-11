import 'dart:math';

import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

enum SortOption { newest, priceLowHigh, priceHighLow, nameAsc }

enum AvailabilityFilter { available, all, out }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.newest:
        return 'Nouveautes';
      case SortOption.priceLowHigh:
        return 'Prix croissant';
      case SortOption.priceHighLow:
        return 'Prix decroissant';
      case SortOption.nameAsc:
        return 'Nom A-Z';
    }
  }
}

extension AvailabilityFilterLabel on AvailabilityFilter {
  String get label {
    switch (this) {
      case AvailabilityFilter.available:
        return 'Disponible';
      case AvailabilityFilter.all:
        return 'Tous';
      case AvailabilityFilter.out:
        return 'Rupture';
    }
  }
}

class ShopState extends ChangeNotifier {
  ShopState({ApiService? api, LocalStorageService? storage, AuthService? auth})
      : _api = api ?? const ApiService(),
        _storage = storage ?? LocalStorageService(),
        _auth = auth ?? AuthService(storage: storage ?? LocalStorageService());

  final ApiService _api;
  final LocalStorageService _storage;
  final AuthService _auth;

  bool _initialized = false;
  bool _loading = true;
  String _error = '';

  bool _authLoading = false;
  String _authError = '';

  AuthSession? _session;
  AuthUser? _user;

  final List<Product> _products = [];
  final List<CartItem> _cart = [];

  String search = '';
  String selectedCategory = '';
  String selectedCountry = '';
  String selectedCity = '';

  String shippingCountry = 'Cameroun';
  String shippingCity = '';

  SortOption _sort = SortOption.newest;
  AvailabilityFilter _availability = AvailabilityFilter.available;
  RangeValues _priceBounds = const RangeValues(0, 0);
  RangeValues _priceRange = const RangeValues(0, 0);

  bool get isInitialized => _initialized;
  bool get isLoading => _loading;
  String get error => _error;

  bool get isAuthLoading => _authLoading;
  String get authError => _authError;
  bool get isAuthenticated => _session != null;
  AuthUser? get user => _user;

  List<Product> get products => List.unmodifiable(_products);
  List<CartItem> get cart => List.unmodifiable(_cart);

  int get cartCount => _cart.fold(0, (a, b) => a + b.quantity);
  double get cartTotal => _cart.fold(0, (a, b) => a + b.total);

  SortOption get sortOption => _sort;
  AvailabilityFilter get availabilityFilter => _availability;
  RangeValues get priceBounds => _priceBounds;
  RangeValues get priceRange => _priceRange;

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
    final minPrice = _priceRange.start;
    final maxPrice = _priceRange.end;

    final filtered = _products.where((p) {
      final okSearch = q.isEmpty ||
          ('${p.name} ${p.description} ${p.country} ${p.city} ${p.category}'.toLowerCase().contains(q));
      final okCategory = selectedCategory.isEmpty || p.category.toLowerCase() == selectedCategory.toLowerCase();
      final okCountry = selectedCountry.isEmpty || p.country.toLowerCase() == selectedCountry.toLowerCase();
      final okCity = selectedCity.isEmpty || p.city.toLowerCase().contains(selectedCity.toLowerCase());
      final okAvailability = switch (_availability) {
        AvailabilityFilter.available => p.isAvailable,
        AvailabilityFilter.out => !p.isAvailable,
        AvailabilityFilter.all => true,
      };
      final okPrice = _priceBounds.start == _priceBounds.end || (p.price >= minPrice && p.price <= maxPrice);

      return okSearch && okCategory && okCountry && okCity && okAvailability && okPrice;
    }).toList();

    filtered.sort((a, b) {
      switch (_sort) {
        case SortOption.newest:
          final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
          final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
          if (aTime != bTime) return bTime.compareTo(aTime);
          return b.id.compareTo(a.id);
        case SortOption.priceLowHigh:
          return a.price.compareTo(b.price);
        case SortOption.priceHighLow:
          return b.price.compareTo(a.price);
        case SortOption.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });

    return filtered;
  }

  Future<void> initialize() async {
    await _loadCart();
    await _restoreSession();
    _initialized = true;
    notifyListeners();
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
      _updatePriceBounds(list);
    } catch (e) {
      _error = "Impossible de charger les produits depuis l'API production.";
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _restoreSession() async {
    final stored = await _auth.readStoredSession();
    if (stored == null || !stored.isValid) return;

    final refreshed = await _auth.me(stored);
    if (refreshed == null) {
      await _auth.clearStoredSession();
      return;
    }

    _session = refreshed;
    _user = refreshed.user;
  }

  Future<void> login({required String identity, required String password}) async {
    _authLoading = true;
    _authError = '';
    notifyListeners();

    try {
      final session = await _auth.login(identity: identity, password: password, current: _session);
      _session = session;
      _user = session.user;
      await refreshProducts();
    } catch (e) {
      _authError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _authLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    _authLoading = true;
    _authError = '';
    notifyListeners();

    try {
      final session = await _auth.register(
        email: email,
        password: password,
        username: username,
        firstName: firstName,
        lastName: lastName,
        current: _session,
      );
      _session = session;
      _user = session.user;
      await refreshProducts();
    } catch (e) {
      _authError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _authLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (_session == null) return;
    await _auth.logout(_session!);
    _session = null;
    _user = null;
    notifyListeners();
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

  void setSortOption(SortOption value) {
    _sort = value;
    notifyListeners();
  }

  void setAvailabilityFilter(AvailabilityFilter value) {
    _availability = value;
    notifyListeners();
  }

  void setPriceRange(RangeValues value) {
    _priceRange = value;
    notifyListeners();
  }

  void resetFilters() {
    search = '';
    selectedCategory = '';
    selectedCountry = '';
    selectedCity = '';
    _availability = AvailabilityFilter.available;
    _sort = SortOption.newest;
    _priceRange = _priceBounds;
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

  void _updatePriceBounds(List<Product> list) {
    final prices = list.map((e) => e.price).where((e) => e > 0).toList();
    if (prices.isEmpty) {
      _priceBounds = const RangeValues(0, 0);
      _priceRange = const RangeValues(0, 0);
      return;
    }

    final minPrice = prices.reduce(min);
    final maxPrice = prices.reduce(max);
    _priceBounds = RangeValues(minPrice, maxPrice);

    if (_priceRange.start == 0 && _priceRange.end == 0) {
      _priceRange = _priceBounds;
      return;
    }

    final nextStart = _priceRange.start.clamp(minPrice, maxPrice).toDouble();
    final nextEnd = _priceRange.end.clamp(minPrice, maxPrice).toDouble();
    _priceRange = RangeValues(min(nextStart, nextEnd), max(nextStart, nextEnd));
  }
}
