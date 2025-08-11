import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:money_bank/screens/device_verify.dart';
import 'package:money_bank/screens/home_screen.dart';
import 'package:money_bank/screens/login_screen.dart';
import 'package:money_bank/screens/splash_screen.dart';
import 'package:money_bank/services/api_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Bank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => SplashScreen(),
        '/login': (_) => LoginScreen(),
        '/home': (_) => HomeScreen(),
        '/device-verify': (_) => DeviceVerifyScreen(), // FIXED: const हटाया
      },
    );
  }
}
