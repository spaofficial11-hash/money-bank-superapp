import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_bank/services/firebase_service.dart';
import 'package:money_bank/screens/wallet_screen.dart';
import 'package:money_bank/screens/admin_panel.dart';
import 'package:money_bank/screens/device_verify.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FirebaseService>(
          create: (_) => FirebaseService(),
        ),
      ],
      child: const MoneyBankApp(),
    ),
  );
}

class MoneyBankApp extends StatelessWidget {
  const MoneyBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Bank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (_) => const WalletScreen(),
        '/admin': (_) => const AdminPanel(),
        '/device-verify': (_) => const DeviceVerifyScreen(),
      },
    );
  }
}
