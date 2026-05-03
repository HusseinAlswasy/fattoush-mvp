import 'package:customer_app/src/features/auth/data/models/app_user.dart';

class AuthResult {
  const AuthResult({
    required this.accessToken,
    required this.user,
  });

  final String accessToken;
  final AppUser user;

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['accessToken'] as String,
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
