import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  Future<void> sendChatMessage(String chatId, Map<String, dynamic> messageData) {
    return _db.collection('chats').doc(chatId).collection('messages').add(messageData);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChatMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ✅ Added missing sendMessage method
  Future<void> sendMessage(String chatId, String text) async {
    await _db.collection('chats').doc(chatId).collection('messages').add({
      'text': text,
      'senderId': currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
