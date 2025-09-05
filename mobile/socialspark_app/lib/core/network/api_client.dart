import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

class ApiClient {
  final http.Client _client;
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String path) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}$path");
    final res = await _client.get(uri, headers: ApiConfig.defaultHeaders);
    return _handle(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}$path");
    final res = await _client.post(uri, headers: ApiConfig.defaultHeaders, body: jsonEncode(body));
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      try { return jsonDecode(res.body); } catch (_) { return res.body; } // API may return plain string
    }
    throw ApiException(res.statusCode, res.body);
  }
}

class ApiException implements Exception {
  final int code;
  final String message;
  ApiException(this.code, this.message);
  @override
  String toString() => "ApiException($code): $message";
}
