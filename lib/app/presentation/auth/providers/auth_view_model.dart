import 'package:flutter/foundation.dart';
import 'package:peerlink/app/data/services/auth_service.dart';

enum AuthStatus { uninitialized, authenticated, authenticating, unauthenticated }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AuthStatus _status = AuthStatus.uninitialized;
  AuthStatus get status => _status;

  AuthViewModel() {
    _authService.authStateChanges.listen((user) {
      if (user == null) {
        _status = AuthStatus.unauthenticated;
      } else {
        _status = AuthStatus.authenticated;
      }
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _status = AuthStatus.authenticating;
    notifyListeners();
    final user = await _authService.signInWithEmailAndPassword(email, password);
    if (user != null) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // **NEW METHOD: To handle sign up**
  Future<bool> signUp(String email, String password) async {
    _status = AuthStatus.authenticating;
    notifyListeners();
    final user = await _authService.signUpWithEmailAndPassword(email, password);
    if (user != null) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
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