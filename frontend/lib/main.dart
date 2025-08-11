import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'screens/wallet_screen.dart';
import 'screens/admin_panel.dart';
import 'screens/device_verify.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MoneyBankApp());
}

class MoneyBankApp extends StatelessWidget {
  const MoneyBankApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FirebaseService>(
          create: (_) => FirebaseService(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Money Bank',
        theme: ThemeData(primarySwatch: Colors.green),
        initialRoute: '/',
        routes: {
          '/': (_) => const WalletScreen(),
          '/admin': (_) => const AdminPanel(),
          '/device-verify': (_) => const DeviceVerifyScreen(),
        },
      ),
    );
  }
}
