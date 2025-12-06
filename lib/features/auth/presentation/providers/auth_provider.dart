import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  static const String defaultEmail = 'demo@healthmate.com';
  static const String defaultPassword = 'password123';

  bool _loggedIn = false;
  String? _email;

  bool get isLoggedIn => _loggedIn;
  String? get email => _email;

  Future<void> login(String email, String password) async {
    _loggedIn = true;
    _email = email.trim().isEmpty ? defaultEmail : email.trim();
    notifyListeners();
  }

  Future<void> logout() async {
    _loggedIn = false;
    _email = null;
    notifyListeners();
  }
}
