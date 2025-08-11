// lib/screens/device_verify.dart
import 'package:flutter/material.dart';
import 'package:money_bank/services/api_service.dart';

class DeviceVerifyScreen extends StatefulWidget {
  const DeviceVerifyScreen({Key? key}) : super(key: key);

  @override
  State<DeviceVerifyScreen> createState() => _DeviceVerifyScreenState();
}

class _DeviceVerifyScreenState extends State<DeviceVerifyScreen> {
  final ApiService _apiService = ApiService();
  bool _isVerifying = false;
  String? _message;

  Future<void> _verifyDevice() async {
    setState(() {
      _isVerifying = true;
      _message = null;
    });

    try {
      // FIX: Using sendRequest instead of undefined post()
      final response = await _apiService.sendRequest(
        '/auth/device-verify',
        method: 'POST',
        body: {
          'device_id': '12345', // Replace with actual device ID
        },
      );

      setState(() {
        _message = response['message'] ?? 'Device verification complete';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Verification')),
      body: Center(
        child: _isVerifying
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _verifyDevice,
                    child: const Text('Verify Device'),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      _message!,
                      textAlign: TextAlign.center,
                    ),
                  ]
                ],
              ),
      ),
    );
  }
}
