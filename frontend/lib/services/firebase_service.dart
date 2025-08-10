import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get the currently signed-in user
  User? get currentUser => _auth.currentUser;

  /// Register a new user
  Future<UserCredential> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out the current user
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  /// Get wallet balance
  Future<double> getWalletBalance(String userId) async {
    final doc = await _db.collection('wallets').doc(userId).get();
    if (doc.exists && doc.data() != null && doc.data()!['balance'] != null) {
      return (doc.data()!['balance'] as num).toDouble();
    }
    return 0.0;
  }

  /// Deposit money into wallet
  Future<void> deposit(String userId, double amount) async {
    final walletRef = _db.collection('wallets').doc(userId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(walletRef);
      if (!snapshot.exists) {
        transaction.set(walletRef, {'balance': amount});
      } else {
        final newBalance =
            (snapshot['balance'] as num).toDouble() + amount;
        transaction.update(walletRef, {'balance': newBalance});
      }
    });
  }

  /// Withdraw money from wallet
  Future<void> withdraw(String userId, double amount) async {
    final walletRef = _db.collection('wallets').doc(userId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(walletRef);
      if (!snapshot.exists) throw Exception('Wallet not found');
      final currentBalance =
          (snapshot['balance'] as num).toDouble();
      if (currentBalance < amount) throw Exception('Insufficient funds');
      final newBalance = currentBalance - amount;
      transaction.update(walletRef, {'balance': newBalance});
    });
  }

  /// Send a chat message
  Future<void> sendMessage(String chatId, Map<String, dynamic> messageData) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);
  }

  /// Stream chat messages for a given chatId
  Stream<QuerySnapshot<Map<String, dynamic>>> getChatMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
