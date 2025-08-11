// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http';

class ApiService {
  // TODO: replace with your backend base URL, no trailing slash
  final String _baseUrl = "https://your-backend-domain.com/api";

  ApiService();

  /// Generic GET
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final uri = Uri.parse("$_baseUrl$endpoint");
    final response = await http.get(uri, headers: headers ?? {
      'Content-Type': 'application/json',
    });

    return _processResponse(response);
  }

  /// Generic POST
  Future<dynamic> post(String endpoint, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    final uri = Uri.parse("$_baseUrl$endpoint");
    final response = await http.post(
      uri,
      headers: headers ?? {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    return _processResponse(response);
  }

  /// Generic PUT
  Future<dynamic> put(String endpoint, Map<String, dynamic> body,
      {Map<String, String>? headers}) async {
    final uri = Uri.parse("$_baseUrl$endpoint");
    final response = await http.put(
      uri,
      headers: headers ?? {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    return _processResponse(response);
  }

  /// Generic DELETE
  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    final uri = Uri.parse("$_baseUrl$endpoint");
    final response = await http.delete(uri, headers: headers ?? {
      'Content-Type': 'application/json',
    });

    return _processResponse(response);
  }

  /// Centralized response handler
  dynamic _processResponse(http.Response response) {
    final status = response.statusCode;
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (status >= 200 && status < 300) {
      return body;
    }

    // Throw a helpful error
    throw Exception('API Error: $status - ${body ?? response.reasonPhrase}');
  }
}
