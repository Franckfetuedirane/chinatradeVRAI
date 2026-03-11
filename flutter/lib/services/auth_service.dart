import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/auth_session.dart';
import '../models/auth_user.dart';
import 'local_storage_service.dart';

class AuthService {
  AuthService({http.Client? client, LocalStorageService? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? LocalStorageService();

  final http.Client _client;
  final LocalStorageService _storage;

  Future<AuthSession?> readStoredSession() => _storage.readAuth();

  Future<void> persistSession(AuthSession session) => _storage.writeAuth(session);

  Future<void> clearStoredSession() => _storage.clearAuth();

  Future<AuthSession> ensureCsrf(AuthSession? session) async {
    final uri = Uri.parse(AppConfig.apiCsrfUrl);
    final response = await _client.get(uri, headers: _headers(session));
    final body = _decodeBody(response);

    final cookies = _extractCookies(response.headers['set-cookie']);
    var csrfToken = cookies['csrftoken'] ?? (body['csrfToken']?.toString() ?? '');
    if (csrfToken.isEmpty) {
      csrfToken = session?.csrfToken ?? '';
    }
    final sessionId = cookies['sessionid'] ?? (session?.sessionId ?? '');

    return AuthSession(
      sessionId: sessionId,
      csrfToken: csrfToken,
      user: session?.user,
    );
  }

  Future<AuthSession> login({
    required String identity,
    required String password,
    AuthSession? current,
  }) async {
    final session = await ensureCsrf(current);
    final response = await _client.post(
      Uri.parse(AppConfig.apiLoginUrl),
      headers: _headers(session, includeCsrf: true),
      body: jsonEncode({'username': identity, 'password': password}),
    );

    final data = _decodeBody(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['detail']?.toString() ?? 'Connexion impossible.');
    }

    final cookies = _extractCookies(response.headers['set-cookie']);
    final next = session.copyWith(
      sessionId: cookies['sessionid'] ?? session.sessionId,
      csrfToken: cookies['csrftoken'] ?? session.csrfToken,
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
    final session = await ensureCsrf(current);
    final response = await _client.post(
      Uri.parse(AppConfig.apiRegisterUrl),
      headers: _headers(session, includeCsrf: true),
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

    final cookies = _extractCookies(response.headers['set-cookie']);
    final next = session.copyWith(
      sessionId: cookies['sessionid'] ?? session.sessionId,
      csrfToken: cookies['csrftoken'] ?? session.csrfToken,
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
    final refreshed = await ensureCsrf(session);
    await _client.post(
      Uri.parse(AppConfig.apiLogoutUrl),
      headers: _headers(refreshed, includeCsrf: true),
    );
    await clearStoredSession();
  }

  Map<String, String> _headers(AuthSession? session, {bool includeCsrf = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final cookies = <String>[];
    if (session?.csrfToken.isNotEmpty == true) {
      cookies.add('csrftoken=${session!.csrfToken}');
      if (includeCsrf) {
        headers['X-CSRFToken'] = session.csrfToken;
      }
    }
    if (session?.sessionId.isNotEmpty == true) {
      cookies.add('sessionid=${session!.sessionId}');
    }
    if (cookies.isNotEmpty) {
      headers['Cookie'] = cookies.join('; ');
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

  Map<String, String> _extractCookies(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    final matches = RegExp(r'(csrftoken|sessionid)=([^;]+)').allMatches(raw);
    final result = <String, String>{};
    for (final m in matches) {
      result[m.group(1)!] = m.group(2)!;
    }
    return result;
  }
}
