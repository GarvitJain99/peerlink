import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:peerlink/app/data/services/auth_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  authenticating,
  unauthenticated,
}

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AuthStatus _status = AuthStatus.uninitialized;
  String? _errorMessage;
  bool _isEmailVerified = false;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isEmailVerified => _isEmailVerified;

  AuthViewModel() {
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _isEmailVerified = user.isEmailVerified;
        _status = AuthStatus.authenticated;
      } else {
        _isEmailVerified = false;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  Future<void> checkEmailVerification() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final isVerified =
        FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (isVerified != _isEmailVerified) {
      _isEmailVerified = isVerified;
      notifyListeners();
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Please fill in both fields.';
      notifyListeners();
      return false;
    }

    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      // The listener will handle status change, so we just return true
      return user != null;
    } on InvalidEmailFormatException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          _errorMessage = 'Invalid email or password. Please try again.';
          break;
        case 'network-request-failed':
          _errorMessage = 'No internet connection. Please try again.';
          break;
        default:
          _errorMessage = 'An unexpected error occurred. Please try again.';
      }
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // To handle sign up
  Future<bool> signUp(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Please fill in both fields.';
      notifyListeners();
      return false;
    }

    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.signUpWithEmailAndPassword(
        email,
        password,
      );
      // The listener will handle status change, so we just return true
      return user != null;
    } on InvalidEmailFormatException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage = 'An account already exists with this email.';
          break;
        case 'weak-password':
          _errorMessage =
              'Password is too weak. It must be at least 6 characters long.';
          break;
        case 'network-request-failed':
          _errorMessage = 'No internet connection. Please try again.';
          break;
        default:
          _errorMessage = 'An unexpected error occurred. Please try again.';
      }
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
