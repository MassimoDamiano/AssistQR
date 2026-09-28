import 'package:flutter/foundation.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  LoginResponse? _loginResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LoginResponse? get loginResponse => _loginResponse;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _loginResponse = null;
    notifyListeners();

    try {
      final request = LoginRequest(email: email.trim(), password: password);

      _loginResponse = await _authService.login(request);

      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
