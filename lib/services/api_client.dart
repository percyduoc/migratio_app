import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'auth_service.dart';

class ApiClient {
  final AuthService auth;
  ApiClient(this.auth);

  Uri _u(String path, [Map<String, String>? params]) {
    final base = apiBaseUrl.endsWith('/') ? apiBaseUrl.substring(0, apiBaseUrl.length - 1) : apiBaseUrl;
    return Uri.parse('$base$path').replace(queryParameters: params);
  }

  Map<String, String> _headers({bool jsonBody = true}) {
    final h = <String, String>{};
    if (jsonBody) h['Content-Type'] = 'application/json';
    if (auth.token != null) h['Authorization'] = 'Bearer ${auth.token}';
    return h;
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final r = await http.post(_u(path), headers: _headers(), body: jsonEncode(body));
    final data = jsonDecode(r.body.isNotEmpty ? r.body : '{}') as Map<String, dynamic>;
    if (r.statusCode >= 400) throw Exception(data['error'] ?? 'HTTP ${r.statusCode}');
    return data;
  }

  Future<Map<String, dynamic>> getJson(String path, [Map<String, String>? params]) async {
    final r = await http.get(_u(path, params), headers: _headers(jsonBody: false));
    final data = jsonDecode(r.body.isNotEmpty ? r.body : '{}') as Map<String, dynamic>;
    if (r.statusCode >= 400) throw Exception(data['error'] ?? 'HTTP ${r.statusCode}');
    return data;
  }

  Future<List<dynamic>> getList(String path, [Map<String, String>? params]) async {
    final r = await http.get(_u(path, params), headers: _headers(jsonBody: false));
    final data = jsonDecode(r.body.isNotEmpty ? r.body : '[]');
    if (r.statusCode >= 400) throw Exception('HTTP ${r.statusCode}: $data');
    if (data is List) return data;
    return data['items'] ?? [];
  }

  Future<Map<String, dynamic>> putJson(String path, Map<String, dynamic> body) async {
    final r = await http.put(_u(path), headers: _headers(), body: jsonEncode(body));
    final data = jsonDecode(r.body.isNotEmpty ? r.body : '{}') as Map<String, dynamic>;
    if (r.statusCode >= 400) throw Exception(data['error'] ?? 'HTTP ${r.statusCode}');
    return data;
  }


  Future<Map<String, dynamic>> getMap(String path) async {
    final j = await getJson(path);
    if (j is Map<String, dynamic>) return j;
    throw 'Se esperaba objeto JSON';
  }



}
