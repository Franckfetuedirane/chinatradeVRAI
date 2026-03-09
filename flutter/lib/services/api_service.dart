import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/product.dart';

class ApiService {
  const ApiService();

  Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse(AppConfig.apiProductsUrl);
    final response = await http.get(uri).timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API error ${response.statusCode}');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Unexpected API payload');
    }

    return decoded
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
