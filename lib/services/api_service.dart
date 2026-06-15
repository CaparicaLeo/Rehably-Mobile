import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._();
  factory ApiService() => _instance;
  ApiService._();

  String? _token;

  Future<String?> get token async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(ApiConfig.tokenKey);
    return _token;
  }

  Future<void> setToken(String? newToken) async {
    _token = newToken;
    final prefs = await SharedPreferences.getInstance();
    if (newToken != null) {
      await prefs.setString(ApiConfig.tokenKey, newToken);
    } else {
      await prefs.remove(ApiConfig.tokenKey);
    }
  }

  Future<Map<String, String>> _headers() async {
    final t = await token;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      if (t != null) 'Authorization': 'Bearer $t',
    };
  }

  Future<Map<String, String>> _multipartHeaders() async {
    final t = await token;
    return {
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      if (t != null) 'Authorization': 'Bearer $t',
    };
  }

  Future<dynamic> get(String path) async {
    final url = '${ApiConfig.baseUrl}$path';
    debugPrint('[API] GET $url');
    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final url = '${ApiConfig.baseUrl}$path';
    debugPrint('[API] POST $url');
    if (body != null) debugPrint('[API] Body: $body');
    final response = await http.post(
      Uri.parse(url),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> postMultipart(
    String path, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) async {
    final url = '${ApiConfig.baseUrl}$path';
    debugPrint('[API] POST (multipart) $url');
    if (fields != null) debugPrint('[API] Fields: $fields');
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(await _multipartHeaders());
    if (fields != null) request.fields.addAll(fields);
    if (files != null) request.files.addAll(files);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final url = '${ApiConfig.baseUrl}$path';
    debugPrint('[API] PUT $url');
    if (body != null) debugPrint('[API] Body: $body');
    final response = await http.put(
      Uri.parse(url),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final url = '${ApiConfig.baseUrl}$path';
    debugPrint('[API] DELETE $url');
    final response = await http.delete(
      Uri.parse(url),
      headers: await _headers(),
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    debugPrint('[API] Response ${response.statusCode}: ${response.body.length > 500 ? "${response.body.substring(0, 500)}..." : response.body}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.statusCode == 204 || response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    }
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    final message = body is Map ? (body['message'] ?? 'Erro desconhecido') : 'Erro desconhecido';
    throw ApiException(
      statusCode: response.statusCode,
      message: message as String,
      errors: body is Map ? body['errors'] : null,
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic errors;

  ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  @override
  String toString() => message;
}
