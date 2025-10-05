import 'package:firebase_auth/firebase_auth.dart';
import 'package:peerlink/app/data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream to listen for authentication changes
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  // Helper method to convert Firebase User to our AppUser model
  AppUser? _userFromFirebase(User? user) {
    if (user == null) {
      return null;
    }
    return AppUser(uid: user.uid, email: user.email ?? '');
  }

  // Sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebase(userCredential.user);
    } on FirebaseAuthException catch (e) {
      print('Sign in failed: ${e.message}');
      return null;
    }
  }

  // **NEW METHOD: Sign up with email and password**
  Future<AppUser?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebase(userCredential.user);
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., weak password, email already in use)
      print('Sign up failed: ${e.message}');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}