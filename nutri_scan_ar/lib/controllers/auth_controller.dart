import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Carga sesión guardada al iniciar la app
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    if (userData != null) {
      _user = UserModel.fromJson(jsonDecode(userData));
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800)); // simula red

    // Validación básica (luego conectamos Firebase)
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Completa todos los campos';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'La contraseña debe tener al menos 6 caracteres';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Usuario de prueba
    _user = UserModel(
      id: '001',
      name: email.split('@').first,
      email: email,
    );

    await _saveSession();
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _errorMessage = 'Completa todos los campos';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (!email.contains('@')) {
      _errorMessage = 'Ingresa un correo válido';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'La contraseña debe tener al menos 6 caracteres';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
    );

    await _saveSession();
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    _user = null;
    notifyListeners();
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(_user!.toJson()));
  }
}