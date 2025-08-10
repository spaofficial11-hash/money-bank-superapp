import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/wallet_card.dart';
import '../widgets/deposit_button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
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
      _showMessage('Error loading wallet: $e');
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
        _showMessage('Deposit successful!');
      } catch (e) {
        _showMessage('Deposit failed: $e');
      }
    }
  }

  Future<void> _withdraw() async {
    final amount = await _showAmountDialog('Withdraw Amount');
    if (amount != null) {
      try {
        await context.read<ApiService>().withdraw(amount);
        _loadWallet();
        _showMessage('Withdrawal successful!');
      } catch (e) {
        _showMessage('Withdraw failed: $e');
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
          decoration: const InputDecoration(hintText: 'Enter amount'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              Navigator.pop(ctx, val);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWallet,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                WalletCard(balance: _balance),
                const SizedBox(height: 20),
                DepositButton(
                  label: 'Deposit',
                  onPressed: _deposit,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _withdraw,
                  child: const Text('Withdraw'),
                ),
              ],
            ),
    );
  }
}
