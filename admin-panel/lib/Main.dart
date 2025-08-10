import 'package:flutter/material.dart';
import 'admin/screens/dashboard.dart';
import 'user/screens/home.dart';

void main() {
  runApp(MoneyBankApp());
}

class MoneyBankApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Bank App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/admin': (context) => AdminDashboard(),
      },
    );
  }
}
