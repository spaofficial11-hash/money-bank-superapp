// lib/screens/wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/rupee_balance.dart';
import '../services/api_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 0.0;
  bool _loading = true;
  final ApiService _api = ApiService();

  static const List<int> amounts = [100, 300, 500, 1000, 2000, 5000, 10000, 30000, 50000];

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { setState(() { _loading = false; }); return; }
    final doc = await FirebaseFirestore.instance.collection('wallets').doc(uid).get();
    setState(() {
      _balance = (doc.data()?['balance'] ?? 0).toDouble();
      _loading = false;
    });
  }

  Future<void> _createDeposit(int amount, String method) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _loading = true);
    try {
      final resp = await _api.sendRequest('/payments/deposit', method: 'POST', body: {
        'uid': uid,
        'amount': amount,
        'method': method,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deposit request created.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deposit failed: $e')));
    } finally {
      await _loadBalance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RupeeBalance(amount: _balance),
            const SizedBox(height: 16),
            const Text('Add Funds', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: amounts.map((a) => ElevatedButton(
                onPressed: () => _showMethodSheet(a),
                child: Text('₹$a'),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showMethodSheet(int amount) {
    showModalBottomSheet(context: context, builder: (ctx) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(title: const Text('Choose payment method')),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Paytm'),
              onTap: () { Navigator.pop(ctx); _createDeposit(amount, 'Paytm'); },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('PhonePe'),
              onTap: () { Navigator.pop(ctx); _createDeposit(amount, 'PhonePe'); },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('GPay'),
              onTap: () { Navigator.pop(ctx); _createDeposit(amount, 'GPay'); },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Navi'),
              onTap: () { Navigator.pop(ctx); _createDeposit(amount, 'Navi'); },
            ),
            ListTile(
              leading: const Icon(Icons.more_horiz),
              title: const Text('Others'),
              onTap: () { Navigator.pop(ctx); _createDeposit(amount, 'Others'); },
            ),
          ],
        ),
      );
    });
  }
}
