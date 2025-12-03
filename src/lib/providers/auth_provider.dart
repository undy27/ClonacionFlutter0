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
  void updateUser(Usuario updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  Future<void> toggleServerPreference(bool useInternet) async {
    if (_currentUser == null) return;

    final success = await PostgresService().updateServerPreference(_currentUser!.id, useInternet);
    if (success) {
      // Update local user state
      // We need to create a copyWith method in Usuario or manually recreate it
      // Since Usuario fields are final, we recreate it using toJson/fromJson hack or manually
      final json = _currentUser!.toJson();
      json['use_internet_server'] = useInternet;
      _currentUser = Usuario.fromJson(json);
      notifyListeners();
    }
  }
}
