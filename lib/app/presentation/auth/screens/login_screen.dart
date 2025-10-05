import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peerlink/app/presentation/auth/providers/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // **NEW: State variable to toggle between Login and Sign Up**
  bool _isLoginMode = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final authViewModel = context.read<AuthViewModel>();

    if (_isLoginMode) {
      authViewModel.signIn(email, password);
    } else {
      authViewModel.signUp(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        // **NEW: Dynamic title**
        title: Text(_isLoginMode ? 'PeerLink Login' : 'Create Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'College Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            authViewModel.status == AuthStatus.authenticating
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitForm,
                    // **NEW: Dynamic button text**
                    child: Text(_isLoginMode ? 'Login' : 'Sign Up'),
                  ),
            // **NEW: Button to switch modes**
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoginMode = !_isLoginMode;
                });
              },
              child: Text(_isLoginMode
                  ? 'Don\'t have an account? Sign Up'
                  : 'Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}