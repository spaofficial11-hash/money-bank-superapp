import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'wallet_screen.dart';

class DeviceVerifyScreen extends StatefulWidget {
  @override
  _DeviceVerifyScreenState createState() => _DeviceVerifyScreenState();
}

class _DeviceVerifyScreenState extends State<DeviceVerifyScreen> {
  final ApiService _apiService = ApiService();
  bool _loading = false;
  String _statusMessage = '';

  Future<void> _verifyDevice() async {
    setState(() {
      _loading = true;
      _statusMessage = '';
    });

    try {
      final response = await _apiService.post('/auth/device-verify', {
        'deviceId': 'sample-device-id', // TODO: Replace with actual device ID
      });

      if (response['verified'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => WalletScreen()),
        );
      } else {
        setState(() {
          _statusMessage = 'Device verification failed.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error verifying device: $e';
      });
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Device Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please verify your device before proceeding.'),
            SizedBox(height: 20),
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyDevice,
                    child: Text('Verify Device'),
                  ),
          ],
        ),
      ),
    );
  }
}
