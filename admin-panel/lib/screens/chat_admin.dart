import 'package:flutter/material.dart';

class ChatAdminScreen extends StatelessWidget {
  const ChatAdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> messages = [
      {'from': 'User 1', 'text': 'Hello, I need help with my deposit.'},
      {'from': 'Admin', 'text': 'Sure, please share your transaction ID.'},
      {'from': 'User 2', 'text': 'How long does withdrawal take?'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isAdmin = msg['from'] == 'Admin';
                return Align(
                  alignment:
                      isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isAdmin ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${msg['from']}: ${msg['text']}'),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration:
                        const InputDecoration(hintText: 'Type your message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    // Send message
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
