import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  double _balance = 0.0;
  double get balance => _balance;

  FirebaseService() {
    _loadUserBalance();
  }

  Future<void> _loadUserBalance() async {
    if (currentUser != null) {
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (doc.exists && doc.data() != null) {
        _balance = (doc.data()!['balance'] ?? 0).toDouble();
        notifyListeners();
      }
    }
  }

  Future<void> updateBalance(double newBalance) async {
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'balance': newBalance,
      });
      _balance = newBalance;
      notifyListeners();
    }
  }

  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
    await _loadUserBalance();
  }
}
