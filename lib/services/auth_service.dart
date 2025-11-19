import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import '../config.dart';

class AuthService extends ChangeNotifier {
  String? token;
  Map<String, dynamic>? user;
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    token = _prefs.getString('token');
    final u = _prefs.getString('user');
    if (u != null) user = jsonDecode(u) as Map<String, dynamic>;
  }

  bool get isLoggedIn => token != null;

  Future<void> signIn(String email, String password) async {
    final api = ApiClient(this);
    final data = await api.postJson('/api/auth/login', {'email': email, 'password': password});
    token = data['token'] as String?;
    user = data['user'] as Map<String, dynamic>?;
    if (token == null) throw Exception('Sin token');
    await _prefs.setString('token', token!);
    await _prefs.setString('user', jsonEncode(user ?? {}));
    notifyListeners();
  }

  Future<void> signUp(Map<String, dynamic> body) async {
    final api = ApiClient(this);
    await api.postJson('/api/auth/signup', body);
    // luego iniciar sesión
    await signIn(body['email'] as String, body['password'] as String);
  }

  Future<void> signOut() async {
    token = null;
    user = null;
    await _prefs.remove('token');
    await _prefs.remove('user');
    notifyListeners();
  }

  Future<Map<String, dynamic>> refreshProfile() async {
    final api = ApiClient(this);
    final me = await api.getJson('/api/users/me');
    user = me;
    await _prefs.setString('user', jsonEncode(user ?? {}));
    notifyListeners();
    return me;
  }

  Future<void> updateProfile(Map<String, dynamic> body) async {
    final api = ApiClient(this);
    final me = await api.putJson('/api/users/me', body);
    user = me;
    await _prefs.setString('user', jsonEncode(user ?? {}));
    notifyListeners();
  }
}
