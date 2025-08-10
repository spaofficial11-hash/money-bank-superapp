import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://your-backend-url.com/api'; // TODO: Update with actual backend URL

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('GET $endpoint failed with status: ${response.statusCode}');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('POST $endpoint failed with status: ${response.statusCode}');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('PUT $endpoint failed with status: ${response.statusCode}');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl$endpoint'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('DELETE $endpoint failed with status: ${response.statusCode}');
    }
  }

  // 🔹 New methods for your app

  Future<dynamic> login(String email, String password) {
    return post('/auth/login', {
      'email': email,
      'password': password,
    });
  }

  Future<dynamic> register(String name, String email, String password) {
    return post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<dynamic> getMlmNetwork() {
    return get('/mlm/network');
  }

  Future<dynamic> getWalletBalance() {
    return get('/wallet/balance');
  }

  Future<dynamic> deposit(double amount) {
    return post('/wallet/deposit', {
      'amount': amount,
    });
  }

  Future<dynamic> withdraw(double amount) {
    return post('/wallet/withdraw', {
      'amount': amount,
    });
  }
}
