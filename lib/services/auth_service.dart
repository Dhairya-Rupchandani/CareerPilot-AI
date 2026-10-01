import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get currentUser => _auth.currentUser;

  // ===========================
  // GOOGLE SIGN IN (v7)
  // ===========================
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Initialize Google Sign-In
      await _googleSignIn.initialize();

      // Show account picker
      final GoogleSignInAccount account =
      await _googleSignIn.authenticate();

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth =
          account.authentication;

      // Firebase credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential =
      await _auth.signInWithCredential(credential);

      // Create Firestore user document
      await FirestoreService().createUserIfNotExist();

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // ===========================
  // SIGN OUT
  // ===========================
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}