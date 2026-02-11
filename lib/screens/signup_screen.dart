import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/data_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 1. Controllers
  final _usernameController = TextEditingController(); // Changed from 'name' to 'username'
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  // 2. State
  bool _isLoading = false;
  bool _isObscured = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // 3. Handle Signup Logic
  Future<void> _handleSignup() async {
    // Basic Validation
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (_passController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call API (Auto-authenticates on success)
      final success = await ApiService().signup(
          _usernameController.text, // "username" field
          _emailController.text,
          _passController.text
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created! Loading...')));
        }

        // 🚀 AUTO-LOGIN: Fetch initial data immediately
        await DataService().loadInitialData();

        if (mounted) {
          // Navigate to Home and remove all previous routes (so back button exits app, doesn't go to login)
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signup failed. Email might be taken.')));
        }
      }
    } catch (e) {
      if (mounted) {
        // Simple error display. In production, you might want to parse "e" to show specific field errors
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Username Input (Changed label to match API)
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Display name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Email Input
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Password Input
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
            const SizedBox(height: 8),

            // Visual Indicator
            Row(
              children: [
                Expanded(child: Container(height: 4, color: Colors.green, margin: const EdgeInsets.only(right: 4))),
                Expanded(child: Container(height: 4, color: Colors.green, margin: const EdgeInsets.only(right: 4))),
                Expanded(child: Container(height: 4, color: Colors.grey[300])),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Strength: Medium', style: TextStyle(fontSize: 12, color: Colors.green)),
            const SizedBox(height: 16),

            // Confirm Password
            TextFormField(
              controller: _confirmPassController,
              obscureText: _isObscured,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 32),

            // Signup Button
            FilledButton(
              onPressed: _isLoading ? null : _handleSignup,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Create Account'),
            ),
            const SizedBox(height: 16),

            // Back to Login
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}