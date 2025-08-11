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
  bool _isLoading = false;
  String _status = '';

  Future<void> _verify() async {
    setState(() { _isLoading = true; _status = ''; });
    try {
      final resp = await _apiService.sendRequest('/auth/device-verify', method: 'POST', body: {
        'device_id': 'sample-device-id', // replace with real device ID
      });
      setState(() { _status = resp['message'] ?? 'Verified'; });
    } catch (e) {
      setState(() { _status = 'Error: $e'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Verification')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading) ElevatedButton(onPressed: _verify, child: const Text('Verify Device')),
            const SizedBox(height: 12),
            Text(_status, textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
