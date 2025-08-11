// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign in anonymously
  Future<User?> signInAnonymously() async {
    try {
      UserCredential credential = await _auth.signInAnonymously();
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Create or update user profile
  Future<void> createOrUpdateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Get user profile
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      rethrow;
    }
  }

  /// Add coins to user
  Future<void> addCoins(String uid, int amount) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'coins': FieldValue.increment(amount),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Deduct coins from user
  Future<void> deductCoins(String uid, int amount) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'coins': FieldValue.increment(-amount),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Save payment history
  Future<void> savePayment(String uid, Map<String, dynamic> paymentData) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('payments')
          .add(paymentData);
    } catch (e) {
      rethrow;
    }
  }

  /// Listen to user coin changes
  Stream<DocumentSnapshot<Map<String, dynamic>>> listenToUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }
}
