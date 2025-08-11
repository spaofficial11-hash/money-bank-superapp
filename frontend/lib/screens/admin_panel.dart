// lib/screens/admin_panel.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  double _adminBalance = 0.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc = await FirebaseFirestore.instance.collection('admin').doc('wallet').get();
    setState(() {
      _adminBalance = (doc.data()?['balance'] ?? 0).toDouble();
      _loading = false;
    });
  }

  Future<void> _refresh() => _load();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Admin Wallet: ₹$_adminBalance', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _refresh, child: const Text('Refresh')),
          const SizedBox(height: 24),
          const Text('Quick Links', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            ElevatedButton(onPressed: () {}, child: const Text('Users')),
            ElevatedButton(onPressed: () {}, child: const Text('Deposits')),
            ElevatedButton(onPressed: () {}, child: const Text('Withdrawals')),
            ElevatedButton(onPressed: () {}, child: const Text('Settings')),
          ])
        ]),
      ),
    );
  }
}
