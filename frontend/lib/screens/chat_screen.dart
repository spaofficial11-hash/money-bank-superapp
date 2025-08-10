import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_bank/services/firebase_service.dart';
import 'package:money_bank/widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatTitle;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.chatTitle,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _sendMessage() async {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;

    await _firebaseService.sendMessage(
      widget.chatId,
      {
        'text': text,
        'senderId': _firebaseService.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      },
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firebaseService.getChatMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data();
                    return ChatBubble(
                      message: message['text'] ?? '',
                      isMe: message['senderId'] ==
                          _firebaseService.currentUser?.uid,
                      timestamp: (message['timestamp'] is Timestamp)
                          ? (message['timestamp'] as Timestamp).toDate()
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
