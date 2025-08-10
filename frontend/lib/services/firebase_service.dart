import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get the currently signed-in user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Sign out the current user
  Future<void> signOut() {
    return _auth.signOut();
  }

  /// Send a chat message (old method)
  Future<void> sendChatMessage(String chatId, Map<String, dynamic> messageData) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);
  }

  /// 🔹 New helper for sending plain text messages
  Future<void> sendMessage(String chatId, String text) {
    return sendChatMessage(chatId, {
      'text': text,
      'senderId': currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
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
