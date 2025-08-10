import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/wallet_card.dart';
import '../widgets/deposit_button.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 0.0;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() => _loading = true);
    try {
      final bal = await context.read<ApiService>().getWalletBalance();
      setState(() => _balance = bal);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading wallet: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deposit() async {
    final amount = await _showAmountDialog('Deposit Amount');
    if (amount != null) {
      try {
        await context.read<ApiService>().deposit(amount);
        _loadWallet();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deposit failed: $e')),
        );
      }
    }
  }

  Future<void> _withdraw() async {
    final amount = await _showAmountDialog('Withdraw Amount');
    if (amount != null) {
      try {
        await context.read<ApiService>().withdraw(amount);
        _loadWallet();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Withdraw failed: $e')),
        );
      }
    }
  }

  Future<double?> _showAmountDialog(String title) async {
    final controller = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'Enter amount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              Navigator.pop(ctx, val);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Wallet'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadWallet,
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                WalletCard(balance: _balance),
                SizedBox(height: 20),
                DepositButton(
                  label: 'Deposit', // FIX: Required label added
                  onPressed: _deposit,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _withdraw,
                  child: Text('Withdraw'),
                ),
              ],
            ),
    );
  }
}
