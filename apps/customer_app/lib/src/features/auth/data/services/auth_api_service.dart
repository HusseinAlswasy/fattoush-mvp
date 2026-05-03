import 'package:customer_app/src/core/network/api_client.dart';
import 'package:customer_app/src/features/auth/data/models/app_user.dart';
import 'package:customer_app/src/features/auth/data/models/auth_result.dart';

class AuthApiService {
  AuthApiService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<AuthResult> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    final response = await _client.postObject(
      '/auth/login',
      body: {
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'password': password,
      },
    );

    return AuthResult.fromJson(response);
  }

  Future<AuthResult> register({
    String? name,
    String? email,
    String? phone,
    required String password,
  }) async {
    final response = await _client.postObject(
      '/auth/register',
      body: {
        if (name != null && name.isNotEmpty) 'name': name,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'password': password,
      },
    );

    return AuthResult.fromJson(response);
  }

  Future<AppUser> getMe(String token) async {
    final response = await _client.getObject('/auth/me', token: token);
    return AppUser.fromJson(response);
  }
}
