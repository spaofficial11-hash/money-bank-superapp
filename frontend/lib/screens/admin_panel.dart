import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final ApiService _apiService = ApiService();
  bool _loading = false;
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _loading = true);
    try {
      final data = await _apiService.get('/admin/users');
      setState(() {
        _users = data ?? [];
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
    setState(() => _loading = false);
  }

  Future<void> _blockUser(String userId) async {
    try {
      await _apiService.post('/admin/block', {'userId': userId});
      _fetchUsers();
    } catch (e) {
      print('Error blocking user: $e');
    }
  }

  Future<void> _unblockUser(String userId) async {
    try {
      await _apiService.post('/admin/unblock', {'userId': userId});
      _fetchUsers();
    } catch (e) {
      print('Error unblocking user: $e');
    }
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    return ListTile(
      title: Text(user['name'] ?? 'Unknown'),
      subtitle: Text(user['email'] ?? ''),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (user['blocked'] == true)
            IconButton(
              icon: Icon(Icons.lock_open, color: Colors.green),
              onPressed: () => _unblockUser(user['id']),
            )
          else
            IconButton(
              icon: Icon(Icons.lock, color: Colors.red),
              onPressed: () => _blockUser(user['id']),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchUsers,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                return _buildUserTile(_users[index]);
              },
            ),
    );
  }
}
