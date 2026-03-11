import 'auth_user.dart';

class AuthSession {
  final String sessionId;
  final String csrfToken;
  final AuthUser? user;

  const AuthSession({
    required this.sessionId,
    required this.csrfToken,
    required this.user,
  });

  bool get isValid => sessionId.isNotEmpty;

  AuthSession copyWith({String? sessionId, String? csrfToken, AuthUser? user}) {
    return AuthSession(
      sessionId: sessionId ?? this.sessionId,
      csrfToken: csrfToken ?? this.csrfToken,
      user: user ?? this.user,
    );
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return AuthSession(
      sessionId: (json['sessionId'] ?? '').toString(),
      csrfToken: (json['csrfToken'] ?? '').toString(),
      user: userJson is Map<String, dynamic> ? AuthUser.fromJson(userJson) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'csrfToken': csrfToken,
        'user': user?.toJson(),
      };
}
