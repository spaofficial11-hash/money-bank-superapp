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

  /// Send a chat message
  Future<void> sendChatMessage(String chatId, Map<String, dynamic> messageData) {
    return _db
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

  /// Create or update a user profile
  Future<void> setUserProfile(String uid, Map<String, dynamic> data) {
    return _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  /// Get user profile stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }
}
