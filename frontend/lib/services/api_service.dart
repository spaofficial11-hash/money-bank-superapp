import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = "https://your-backend-domain.com/api"; // अपना backend URL डालो

  /// GET request
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final Uri url = Uri.parse("$_baseUrl$endpoint");
    final response = await http.get(url, headers: headers);

    return _processResponse(response);
  }

  /// POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    final Uri url = Uri.parse("$_baseUrl$endpoint");

    final response = await http.post(
      url,
      headers: headers ?? {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return _processResponse(response);
  }

  /// PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    final Uri url = Uri.parse("$_baseUrl$endpoint");

    final response = await http.put(
      url,
      headers: headers ?? {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return _processResponse(response);
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    final Uri url = Uri.parse("$_baseUrl$endpoint");
    final response = await http.delete(url, headers: headers);

    return _processResponse(response);
  }

  /// Response handler
  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else {
      throw Exception(
        "API Error: $statusCode - ${body ?? response.reasonPhrase}",
      );
    }
  }
}
