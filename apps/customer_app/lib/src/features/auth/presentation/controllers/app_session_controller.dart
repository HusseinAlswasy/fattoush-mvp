import 'package:customer_app/src/features/auth/data/models/app_user.dart';
import 'package:customer_app/src/features/auth/data/services/auth_api_service.dart';
import 'package:flutter/foundation.dart';

class AppSessionController extends ChangeNotifier {
  AppSessionController({AuthApiService? authApiService})
      : _authApiService = authApiService ?? AuthApiService();

  final AuthApiService _authApiService;

  AppUser? _user;
  String? _accessToken;
  bool _guestMode = false;
  bool _isLoading = false;

  AppUser? get user => _user;
  String? get accessToken => _accessToken;
  bool get isGuest => _guestMode;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get isAdmin => _user?.role == AppUserRole.admin;
  bool get isCustomer => _user?.role == AppUserRole.customer;
  bool get isDriver => _user?.role == AppUserRole.driver;

  void updateUser(AppUser user) {
    _user = user;
    notifyListeners();
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final cleanedIdentifier = identifier.trim();
      final cleanedPassword = password.trim();
      final email = cleanedIdentifier.contains('@') ? cleanedIdentifier : null;
      final phone = email == null ? cleanedIdentifier : null;
      final result = await _authApiService.login(
        email: email,
        phone: phone,
        password: cleanedPassword,
      );
      _accessToken = result.accessToken;
      _user = result.user;
      _guestMode = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    String? name,
    required String identifier,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final cleanedIdentifier = identifier.trim();
      final cleanedPassword = password.trim();
      final email = cleanedIdentifier.contains('@') ? cleanedIdentifier : null;
      final phone = email == null ? cleanedIdentifier : null;
      final result = await _authApiService.register(
        name: name?.trim(),
        email: email,
        phone: phone,
        password: cleanedPassword,
      );
      _accessToken = result.accessToken;
      _user = result.user;
      _guestMode = false;
    } finally {
      _setLoading(false);
    }
  }

  void continueAsGuest() {
    _guestMode = true;
    _user = null;
    _accessToken = null;
    notifyListeners();
  }

  void logout() {
    _guestMode = false;
    _user = null;
    _accessToken = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
