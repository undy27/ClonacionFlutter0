import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/postgres_service.dart';

class AuthProvider with ChangeNotifier {
  Usuario? _currentUser;
  bool _isLoading = false;

  Usuario? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  // Initialize DB schema (temporary)
  Future<void> init() async {
    await PostgresService().initAuthTables();
  }

  Future<bool> login(String alias, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await PostgresService().login(alias, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String alias, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await PostgresService().register(alias, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginAsGuest(String alias) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await PostgresService().createGuest(alias);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
