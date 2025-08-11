// lib/widgets/chat_bubble.dart
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  const ChatBubble({super.key, required this.text, this.isMe = false});

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? Colors.green[100] : Colors.grey[200];
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isMe
        ? const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomLeft: Radius.circular(12))
        : const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomRight: Radius.circular(12));
    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: bg, borderRadius: radius),
          child: Text(text),
        )
      ],
    );
  }
}
