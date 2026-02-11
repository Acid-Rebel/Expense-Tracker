import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/data_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscured = true;
  // Use these credentials to test against your backend or change to empty
  final _emailController = TextEditingController(text: "user@example.com");
  final _passController = TextEditingController(text: "password123");
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final success = await ApiService().login(_emailController.text, _passController.text);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loading your data...')));
        }
        // Pre-fetch all data (Expenses, Groups, Categories) before going Home
        await DataService().loadInitialData();

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.account_balance_wallet, size: 60, color: Colors.indigo),
              const SizedBox(height: 20),
              const Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passController,
                obscureText: _isObscured,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Login'),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}