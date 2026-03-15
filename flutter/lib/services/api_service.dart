import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/product.dart';
import 'http_client_factory.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? createHttpClient();

  final http.Client _client;

  Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse(AppConfig.apiProductsUrl);
    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));

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
