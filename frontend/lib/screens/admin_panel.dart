import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({Key? key}) : super(key: key);

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAdminBalance();
  }

  Future<void> _loadAdminBalance() async {
    final doc = await FirebaseFirestore.instance.collection('admin').doc('wallet').get();
    if (doc.exists && doc.data() != null) {
      setState(() {
        _balance = (doc.data()!['balance'] ?? 0).toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Wallet Balance: ₹$_balance',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadAdminBalance,
              child: const Text('Refresh Balance'),
            ),
          ],
        ),
      ),
    );
  }
}
