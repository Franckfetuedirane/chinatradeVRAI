import 'auth_user.dart';

class AuthSession {
  final String token;
  final AuthUser? user;

  const AuthSession({
    required this.token,
    required this.user,
  });

  bool get isValid => token.isNotEmpty || user != null;

  AuthSession copyWith({String? token, AuthUser? user}) {
    return AuthSession(
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return AuthSession(
      token: (json['token'] ?? '').toString(),
      user: userJson is Map<String, dynamic> ? AuthUser.fromJson(userJson) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'user': user?.toJson(),
      };
}
