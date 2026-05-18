import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  // Android emulator → 10.0.2.2 reaches host machine localhost.
  // Linux / macOS / Windows desktop and iOS simulator → localhost directly.
  // Physical Android device → change 10.0.2.2 to your machine's LAN IP.
  static String get _base {
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    return 'http://$host:8080/api';
  }

  Uri _uri(String path, [Map<String, String>? params]) {
    final uri = Uri.parse('$_base$path');
    return params != null ? uri.replace(queryParameters: params) : uri;
  }

  Future<dynamic> get(String path, {Map<String, String>? params}) async {
    final res = await http.get(_uri(path, params));
    _check(res);
    return jsonDecode(res.body);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    _check(res);
    return jsonDecode(res.body);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final res = await http.patch(
      _uri(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    _check(res);
    return jsonDecode(res.body);
  }

  void _check(http.Response res) {
    if (res.statusCode >= 400) throw ApiException(res.statusCode, res.body);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
