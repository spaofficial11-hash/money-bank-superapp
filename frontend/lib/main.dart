import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'screens/auth_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/mlm_dashboard.dart';
import 'screens/chat_screen.dart';
import 'screens/admin_panel.dart';
import 'screens/device_verify.dart';
import 'services/api_service.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MoneyBankApp());
}

class MoneyBankApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => FirebaseService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Money Bank',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/auth',
        routes: {
          '/auth': (_) => AuthScreen(),
          '/wallet': (_) => WalletScreen(),
          '/mlm': (_) => MlmDashboard(),
          '/chat': (_) => ChatScreen(),
          '/admin': (_) => AdminPanel(),
          '/verify-device': (_) => DeviceVerifyScreen(),
        },
      ),
    );
  }
}
