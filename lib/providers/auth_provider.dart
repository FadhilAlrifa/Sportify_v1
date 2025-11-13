import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _userId;
  String? get userId => _userId;

  bool get isLoggedIn => _userId != null;

  Future<bool> login(String email, String password) async {
// Ganti dengan Firebase atau API
    await Future.delayed(const Duration(seconds: 1));
    _userId = 'user-123';
    notifyListeners();
    return true;
  }

  Future<bool> register(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _userId = 'user-123';
    notifyListeners();
    return true;
  }

  void logout() {
    _userId = null;
    notifyListeners();
  }
}
