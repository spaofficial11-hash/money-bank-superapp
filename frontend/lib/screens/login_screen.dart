// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _loginWithEmail() async {
    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      final pass = _passwordController.text;
      if (email.isEmpty || pass.isEmpty) {
        throw Exception('Email and password required');
      }
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _registerEmail() async {
    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      final pass = _passwordController.text;
      if (email.isEmpty || pass.isEmpty) {
        throw Exception('Email and password required');
      }
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Register failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _anonymous() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Anonymous login failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            _loading ? const CircularProgressIndicator() : Column(
              children: [
                ElevatedButton(onPressed: _loginWithEmail, child: const Text('Login with Email')),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _registerEmail, child: const Text('Register with Email')),
                const SizedBox(height: 8),
                TextButton(onPressed: _anonymous, child: const Text('Continue as Guest')),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/device-verify'),
                  child: const Text('Device Verification'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
