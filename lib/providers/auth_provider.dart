import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dart:convert'; // 🔄 Pour json, base64, utf8
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;
  bool _isOrganizer = false;
  bool _isLoading = true;

  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  bool get isOrganizer => _isOrganizer;

  AuthProvider() {
    loadTokenAndRole();
  }

  Future<void> loadTokenAndRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _isOrganizer = prefs.getBool('isOrganizer') ?? false;
    print("🔄 Token restauré : $_token");
    print("🧑‍💼 Rôle restauré (organisateur) : $_isOrganizer");
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final token = await _apiService.login(email, password);
    if (token != null) {
      _token = token;

      // 🧠 Analyse du rôle à partir du token JWT
      final payload = _decodeJwtPayload(token);
      final roles = payload['roles'] ?? [];

      _isOrganizer = roles.contains('ROLE_ORGANIZER');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setBool('isOrganizer', _isOrganizer);

      print("🔐 Token stocké : $_token");
      print("🧑‍💼 Est organisateur ? $_isOrganizer");

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password, String role) async {
    return await _apiService.register(email, password, role);
  }

  void clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('isOrganizer');
    _token = null;
    _isOrganizer = false;
    notifyListeners();
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));

    return json.decode(decoded);
  }
}
