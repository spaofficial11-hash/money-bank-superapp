// lib/screens/device_verify.dart
import 'package:flutter/material.dart';
import 'package:money_bank/services/api_service.dart';

class DeviceVerifyScreen extends StatefulWidget {
  const DeviceVerifyScreen({super.key});

  @override
  State<DeviceVerifyScreen> createState() => _DeviceVerifyScreenState();
}

class _DeviceVerifyScreenState extends State<DeviceVerifyScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _deviceIdController = TextEditingController();

  Future<void> verifyDevice() async {
    try {
      final response = await _apiService.post(
        '/auth/device-verify',
        {'deviceId': _deviceIdController.text},
      );
      print(response);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device verified successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Device Verification")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _deviceIdController,
              decoration: const InputDecoration(labelText: "Enter Device ID"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: verifyDevice,
              child: const Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}
