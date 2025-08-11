import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double _balance = 0.0;
  double get balance => _balance;

  /// Load wallet balance from Firestore
  Future<void> loadBalance(String uid) async {
    try {
      final doc = await _firestore.collection('wallets').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        // Safely convert any type (int, string, map) into double
        final bal = doc.data()!['balance'];
        if (bal is num) {
          _balance = bal.toDouble();
        } else if (bal is String) {
          _balance = double.tryParse(bal) ?? 0.0;
        } else {
          _balance = 0.0;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading balance: $e');
    }
  }

  /// Update wallet balance
  Future<void> updateBalance(String uid, double amount) async {
    try {
      await _firestore.collection('wallets').doc(uid).update({
        'balance': amount,
      });
      _balance = amount;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating balance: $e');
    }
  }

  /// Add amount to balance
  Future<void> addBalance(String uid, double amount) async {
    try {
      final docRef = _firestore.collection('wallets').doc(uid);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          final currentBal = (snapshot['balance'] ?? 0).toDouble();
          transaction.update(docRef, {
            'balance': currentBal + amount,
          });
          _balance = currentBal + amount;
        } else {
          transaction.set(docRef, {
            'balance': amount,
          });
          _balance = amount;
        }
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding balance: $e');
    }
  }

  /// Deduct amount from balance
  Future<bool> deductBalance(String uid, double amount) async {
    try {
      if (_balance < amount) return false;
      await updateBalance(uid, _balance - amount);
      return true;
    } catch (e) {
      debugPrint('Error deducting balance: $e');
      return false;
    }
  }
}
