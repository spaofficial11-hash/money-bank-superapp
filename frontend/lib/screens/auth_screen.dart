import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _email = '';
  String _password = '';
  String _name = '';
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);

    try {
      if (_isLogin) {
        await context.read<ApiService>().login(_email, _password);
      } else {
        await context.read<ApiService>().register(_name, _email, _password);
      }
      Navigator.pushReplacementNamed(context, '/wallet');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Register')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (!_isLogin)
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (val) =>
                        val!.isEmpty ? 'Enter your name' : null,
                    onSaved: (val) => _name = val!,
                  ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) =>
                      val!.isEmpty ? 'Enter email' : null,
                  onSaved: (val) => _email = val!,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (val) =>
                      val!.length < 6 ? 'Password too short' : null,
                  onSaved: (val) => _password = val!,
                ),
                SizedBox(height: 20),
                _loading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submit,
                        child: Text(_isLogin ? 'Login' : 'Register'),
                      ),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin
                        ? 'Don\'t have an account? Register'
                        : 'Already have an account? Login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
