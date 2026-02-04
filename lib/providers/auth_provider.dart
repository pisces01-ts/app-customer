import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/api_config.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String _errorMessage = '';

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final token = await _storage.getToken();
      if (token == null || token.isEmpty) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      _api.setToken(token);

      // Verify token by getting profile
      final response = await _api.get(ApiConfig.getProfile);
      
      if (response.success && response.data != null) {
        final userData = response.data!['user'] ?? response.data!['data'];
        if (userData != null) {
          _user = UserModel.fromJson(userData);
          _status = AuthStatus.authenticated;
        } else {
          await _logout();
        }
      } else {
        await _logout();
      }
    } catch (e) {
      await _logout();
    }

    notifyListeners();
  }

  Future<bool> login(String phone, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    final response = await _api.post(ApiConfig.login, body: {
      'phone': phone,
      'password': password,
    });

    if (response.success && response.data != null) {
      final token = response.data!['token'];
      final userData = response.data!['user'];

      if (token != null && userData != null) {
        await _storage.saveToken(token);
        await _storage.saveUserId(userData['user_id']);
        await _storage.saveUserData(jsonEncode(userData));

        _api.setToken(token);
        _user = UserModel.fromJson(userData);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
    }

    _errorMessage = response.message;
    _status = AuthStatus.error;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String fullname,
    required String phone,
    required String password,
    String? email,
    String? address,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();

    final response = await _api.post(ApiConfig.register, body: {
      'fullname': fullname,
      'phone': phone,
      'password': password,
      if (email != null && email.isNotEmpty) 'email': email,
      if (address != null && address.isNotEmpty) 'address': address,
    });

    if (response.success) {
      // Auto login after register
      return await login(phone, password);
    }

    _errorMessage = response.message;
    _status = AuthStatus.error;
    notifyListeners();
    return false;
  }

  Future<bool> forgotPassword(String phone) async {
    final response = await _api.post(ApiConfig.forgotPassword, body: {
      'phone': phone,
    });
    
    if (!response.success) {
      _errorMessage = response.message;
    }
    return response.success;
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    final response = await _api.post(ApiConfig.resetPassword, body: {
      'token': token,
      'new_password': newPassword,
      'confirm_password': newPassword,
    });
    
    if (!response.success) {
      _errorMessage = response.message;
    }
    return response.success;
  }

  Future<bool> updateProfile({
    String? fullname,
    String? email,
    String? address,
  }) async {
    final response = await _api.post(ApiConfig.updateProfile, body: {
      if (fullname != null) 'fullname': fullname,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
    });

    if (response.success && _user != null) {
      _user = _user!.copyWith(
        fullname: fullname ?? _user!.fullname,
        email: email ?? _user!.email,
        address: address ?? _user!.address,
      );
      await _storage.saveUserData(jsonEncode(_user!.toJson()));
      notifyListeners();
    } else {
      _errorMessage = response.message;
    }

    return response.success;
  }

  Future<void> logout() async {
    await _logout();
    notifyListeners();
  }

  Future<void> _logout() async {
    await _storage.clearAll();
    _api.setToken(null);
    _user = null;
    _status = AuthStatus.unauthenticated;
  }
}
