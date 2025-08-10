import 'package:flutter/material.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users Management'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 15, // Example data
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text('User ${index + 1}'),
              subtitle: Text('Email: user${index + 1}@example.com'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.block, color: Colors.red),
                    onPressed: () {
                      // Block user
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () {
                      // Approve user
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
