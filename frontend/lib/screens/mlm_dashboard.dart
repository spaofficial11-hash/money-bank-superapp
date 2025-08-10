import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class MlmDashboard extends StatefulWidget {
  @override
  _MlmDashboardState createState() => _MlmDashboardState();
}

class _MlmDashboardState extends State<MlmDashboard> {
  bool _loading = false;
  Map<String, dynamic>? _networkData;

  @override
  void initState() {
    super.initState();
    _loadNetwork();
  }

  Future<void> _loadNetwork() async {
    setState(() => _loading = true);
    try {
      final data = await context.read<ApiService>().getMlmNetwork();
      setState(() => _networkData = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading MLM data: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildNetworkTree(Map<String, dynamic> node, {int level = 0}) {
    final children = node['children'] ?? [];
    return Padding(
      padding: EdgeInsets.only(left: level * 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${node['name']} (${node['id']}) - Earnings: ₹${node['earnings']}'),
          ...children.map<Widget>(
            (child) => _buildNetworkTree(child, level: level + 1),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MLM Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadNetwork,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _networkData == null
              ? Center(child: Text('No data available'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: _buildNetworkTree(_networkData!),
                ),
    );
  }
}
