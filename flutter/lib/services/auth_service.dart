import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';
import 'http_client_factory.dart';
import 'local_storage_service.dart';

class AuthService {
  AuthService({http.Client? client, LocalStorageService? storage})
      : _client = client ?? createHttpClient(withCredentials: true),
        _storage = storage ?? LocalStorageService();

  final http.Client _client;
  final LocalStorageService _storage;

  Future<AuthSession?> readStoredSession() => _storage.readAuth();

  Future<void> persistSession(AuthSession session) => _storage.writeAuth(session);

  Future<void> clearStoredSession() => _storage.clearAuth();

  Future<AuthSession> login({
    required String identity,
    required String password,
    AuthSession? current,
  }) async {
    final response = await _client.post(
      Uri.parse(AppConfig.apiLoginUrl),
      headers: _headers(current),
      body: jsonEncode({'username': identity, 'password': password}),
    );

    final data = _decodeBody(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['detail']?.toString() ?? 'Connexion impossible.');
    }

    final token = data['token']?.toString() ?? '';
    if (token.isEmpty) {
      throw Exception('Token manquant.');
    }
    final next = AuthSession(
      token: token,
      user: data['user'] is Map<String, dynamic> ? AuthUser.fromJson(data['user']) : null,
    );

    await persistSession(next);
    return next;
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
    AuthSession? current,
  }) async {
    final response = await _client.post(
      Uri.parse(AppConfig.apiRegisterUrl),
      headers: _headers(current),
      body: jsonEncode({
        'email': email,
        'password': password,
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
      }),
    );

    final data = _decodeBody(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['detail']?.toString() ?? 'Inscription impossible.');
    }

    final token = data['token']?.toString() ?? '';
    if (token.isEmpty) {
      throw Exception('Token manquant.');
    }
    final next = AuthSession(
      token: token,
      user: data['user'] is Map<String, dynamic> ? AuthUser.fromJson(data['user']) : null,
    );

    await persistSession(next);
    return next;
  }

  Future<AuthSession?> me(AuthSession session) async {
    final response = await _client.get(
      Uri.parse(AppConfig.apiMeUrl),
      headers: _headers(session),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final data = _decodeBody(response);
    final authenticated = data['authenticated'] == true;
    if (!authenticated) return null;

    final user = data['user'] is Map<String, dynamic> ? AuthUser.fromJson(data['user']) : null;
    final refreshed = session.copyWith(user: user);
    await persistSession(refreshed);
    return refreshed;
  }

  Future<void> logout(AuthSession session) async {
    await _client.post(
      Uri.parse(AppConfig.apiLogoutUrl),
      headers: _headers(session),
    );
    await clearStoredSession();
  }

  Map<String, String> _headers(AuthSession? session) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (session?.token.isNotEmpty == true) {
      headers['Authorization'] = 'Token ${session!.token}';
    }
    return headers;
  }

  Map<String, dynamic> _decodeBody(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

}
