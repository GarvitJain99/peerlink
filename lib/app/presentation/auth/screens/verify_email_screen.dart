import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peerlink/app/presentation/auth/providers/auth_view_model.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Check for verification status every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      context.read<AuthViewModel>().checkEmailVerification();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Important to cancel the timer!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? 'your email';

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Email')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'A verification link has been sent to:',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              userEmail,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Waiting for verification... Please check your inbox (and spam folder).',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => authViewModel.sendVerificationEmail(),
              child: const Text('Resend Email'),
            ),
            TextButton(
              onPressed: () => authViewModel.signOut(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}