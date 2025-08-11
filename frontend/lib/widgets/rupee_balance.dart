// lib/widgets/rupee_balance.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RupeeBalance extends StatelessWidget {
  final double amount;
  const RupeeBalance({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Wallet Balance', style: TextStyle(fontSize: 16)),
            Text(formatted, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
