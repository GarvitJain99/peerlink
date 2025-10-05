import 'package:firebase_auth/firebase_auth.dart';
import 'package:peerlink/app/data/models/user_model.dart';

class InvalidEmailFormatException implements Exception {
  final String message;
  InvalidEmailFormatException(this.message);
}

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

  // Log in with email and password
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    final emailRegex = RegExp(r'^[a-zA-Z]+\.[a-zA-Z0-9]+@mnnit\.ac\.in$');

    // 2. Validate the email format before calling Firebase
    if (!emailRegex.hasMatch(email)) {
      throw InvalidEmailFormatException('Invalid email format. Must be firstname.regno@mnnit.ac.in');
    }
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebase(userCredential.user);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Sign up with email and password
  Future<AppUser?> signUpWithEmailAndPassword(String email, String password) async {
    final emailRegex = RegExp(r'^[a-zA-Z]+\.[a-zA-Z0-9]+@mnnit\.ac\.in$');

    // 2. Validate the email format before calling Firebase
    if (!emailRegex.hasMatch(email)) {
      throw InvalidEmailFormatException('Invalid email format. Must be firstname.regno@mnnit.ac.in');
    }
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebase(userCredential.user);
    } on FirebaseAuthException {
      // Handle errors (e.g., weak password, email already in use)
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}