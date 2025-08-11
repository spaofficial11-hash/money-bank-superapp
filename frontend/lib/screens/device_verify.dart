import 'package:flutter/material.dart';
import 'package:money_bank/services/api_service.dart';

class DeviceVerifyScreen extends StatefulWidget {
  const DeviceVerifyScreen({super.key});

  @override
  State<DeviceVerifyScreen> createState() => _DeviceVerifyScreenState();
}

class _DeviceVerifyScreenState extends State<DeviceVerifyScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String _statusMessage = "";

  Future<void> _verifyDevice() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "";
    });

    try {
      // Example device data (तुम अपने अनुसार बदल सकते हो)
      Map<String, dynamic> deviceData = {
        "device_id": "1234567890",
        "platform": "android",
        "version": "1.0.0",
      };

      final response = await _apiService.post(
        "/auth/device-verify",
        deviceData,
      );

      setState(() {
        _statusMessage = "✅ Device Verified: ${response['message'] ?? 'Success'}";
      });

    } catch (e) {
      setState(() {
        _statusMessage = "❌ Verification Failed: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Verification"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading) const CircularProgressIndicator(),
              if (!_isLoading) ElevatedButton(
                onPressed: _verifyDevice,
                child: const Text("Verify Device"),
              ),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
