import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final DateTime? timestamp;
  final bool isMe;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isMe,
    this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final time = timestamp != null
        ? "${timestamp!.hour}:${timestamp!.minute.toString().padLeft(2, '0')}"
        : "";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            if (time.isNotEmpty)
              Text(
                time,
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.black54,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
