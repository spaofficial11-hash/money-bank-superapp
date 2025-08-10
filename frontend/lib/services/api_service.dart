import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://your-backend-url.com/api";

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {"email": email, "password": password},
    );
    return json.decode(res.body);
  }

  // Register
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {"name": name, "email": email, "password": password},
    );
    return json.decode(res.body);
  }

  // Deposit
  Future<Map<String, dynamic>> deposit(double amount) async {
    final res = await http.post(
      Uri.parse('$baseUrl/deposit'),
      body: {"amount": amount.toString()},
    );
    return json.decode(res.body);
  }

  // Withdraw
  Future<Map<String, dynamic>> withdraw(double amount) async {
    final res = await http.post(
      Uri.parse('$baseUrl/withdraw'),
      body: {"amount": amount.toString()},
    );
    return json.decode(res.body);
  }

  // Get Wallet Balance
  Future<Map<String, dynamic>> getWalletBalance() async {
    final res = await http.get(Uri.parse('$baseUrl/wallet/balance'));
    return json.decode(res.body);
  }

  // MLM Network Data
  Future<Map<String, dynamic>> getMlmNetwork() async {
    final res = await http.get(Uri.parse('$baseUrl/mlm/network'));
    return json.decode(res.body);
  }
}
