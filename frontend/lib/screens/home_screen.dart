// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/rupee_balance.dart';
import '../widgets/chat_bubble.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _balance = 0.0;
  bool _loading = true;
  String _banner = 'Welcome to Money Bank!';

  @override
  void initState() {
    super.initState();
    _loadData();
    _listenBanner();
  }

  Future<void> _listenBanner() async {
    FirebaseFirestore.instance.collection('settings').doc('banner').snapshots().listen((doc) {
      if (doc.exists) {
        setState(() {
          _banner = (doc.data()?['message'] ?? 'Welcome to Money Bank!');
        });
      }
    });
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() { _loading = false; });
      return;
    }

    final doc = await FirebaseFirestore.instance.collection('wallets').doc(uid).get();
    setState(() {
      _balance = (doc.data()?['balance'] ?? 0).toDouble();
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Bank'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
          IconButton(onPressed: () => Navigator.pushNamed(context, '/device-verify'), icon: const Icon(Icons.phonelink_lock)),
        ],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Container(
            color: Colors.green.shade700,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(_banner, style: const TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
          RupeeBalance(amount: _balance),
          const SizedBox(height: 12),
          Expanded(
            child: Center(child: Text('Dashboard / Features go here')),
          ),
          const SizedBox(height: 12),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/home'), // placeholder
        child: const Icon(Icons.home),
      ),
    );
  }
}
