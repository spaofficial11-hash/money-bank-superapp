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

  /// ===== Custom App Methods =====

  // Get wallet balance
  Future<double> getWalletBalance() async {
    final result = await get('/wallet/balance');
    return (result['balance'] ?? 0).toDouble();
  }

  // Deposit money
  Future<void> deposit(double amount) async {
    await post('/wallet/deposit', {'amount': amount});
  }

  // Withdraw money
  Future<void> withdraw(double amount) async {
    await post('/wallet/withdraw', {'amount': amount});
  }

  // Get MLM network data
  Future<List<dynamic>> getMlmNetwork() async {
    final result = await get('/mlm/network');
    return result['network'] ?? [];
  }
}
