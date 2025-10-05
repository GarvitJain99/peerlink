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
  // State variable to toggle between Login and Sign Up
  bool _isLoginMode = true;
  bool _isPasswordVisible = false;

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

    // if (email.isEmpty || password.isEmpty) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('Please fill in both fields.')),
    //     );
    //     return;
    // }

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
        // Dynamic title
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
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            if (authViewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  authViewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 16),

            authViewModel.status == AuthStatus.authenticating
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitForm,
                    // Dynamic button text
                    child: Text(_isLoginMode ? 'Login' : 'Sign Up'),
                  ),

            // Button to switch modes
            TextButton(
              onPressed: () {
                context.read<AuthViewModel>().clearError();
                _emailController.clear();
                _passwordController.clear();

                setState(() {
                  _isLoginMode = !_isLoginMode;
                });
              },
              child: Text(
                _isLoginMode
                    ? 'Don\'t have an account? Sign Up'
                    : 'Already have an account? Login',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
