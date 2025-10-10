import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:peerlink/app/data/services/p2p_service.dart';
import 'package:peerlink/app/data/services/library_service.dart';
import 'package:peerlink/app/presentation/auth/providers/auth_view_model.dart';
import 'package:peerlink/app/presentation/auth/screens/login_screen.dart';
import 'package:peerlink/app/presentation/auth/screens/verify_email_screen.dart';
import 'package:peerlink/app/presentation/discovery/providers/discovery_view_model.dart';
import 'package:peerlink/app/presentation/discovery/screens/discovery_screen.dart';
import 'package:peerlink/app/presentation/library/providers/library_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        Provider<P2pService>(create: (_) => P2pService()),
        Provider<LibraryService>(create: (_) => LibraryService()),
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProxyProvider<P2pService, DiscoveryViewModel>(
          create: (context) => DiscoveryViewModel(context.read<P2pService>()),
          update: (context, p2pService, previousViewModel) =>
              DiscoveryViewModel(p2pService),
        ),
        ChangeNotifierProxyProvider<LibraryService, LibraryViewModel>(
          create: (context) => LibraryViewModel(context.read<LibraryService>()),
          update: (context, libraryService, previous) =>
              LibraryViewModel(libraryService),
        ),
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    switch (authViewModel.status) {
      case AuthStatus.authenticated:
        if (authViewModel.isEmailVerified) {
          return const DiscoveryScreen();
        } else {
          return const VerifyEmailScreen();
        }
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      default:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}
