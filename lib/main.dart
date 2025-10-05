import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:peerlink/app/presentation/auth/providers/auth_view_model.dart';
import 'package:peerlink/app/presentation/discovery/providers/discovery_view_model.dart';
import 'package:peerlink/app/presentation/auth/screens/login_screen.dart';
import 'package:peerlink/app/presentation/discovery/screens/discovery_screen.dart';
import 'package:peerlink/app/presentation/auth/screens/verify_email_screen.dart';

void main() async {
  // Ensure Flutter's widget binding is initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(
    // MultiProvider makes multiple providers available to the entire widget tree below it
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DiscoveryViewModel()),
        // You will add other providers here as the app grows
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeerLink',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

// AuthWrapper listens to the authentication state and shows the appropriate screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    if (authViewModel.status == AuthStatus.authenticated) {
      if (authViewModel.isEmailVerified) {
        return const DiscoveryScreen();
      } else {
        return const VerifyEmailScreen();
      }
    } else if (authViewModel.status == AuthStatus.unauthenticated) {
      return const LoginScreen();
    } else {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}