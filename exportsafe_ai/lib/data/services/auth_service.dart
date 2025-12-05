import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Email and Password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in: $e');
      }
      rethrow;
    }
  }

  // Sign up with Email and Password
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      if (kDebugMode) {
        print('Error signing up: $e');
      }
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    // await gsi.GoogleSignIn().signOut();
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    // try {
    //   final gsi.GoogleSignInAccount? googleUser = await gsi.GoogleSignIn().signIn();
    //   if (googleUser == null) return null; // User canceled

    //   final gsi.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    //   final AuthCredential credential = GoogleAuthProvider.credential(
    //     accessToken: googleAuth.accessToken,
    //     idToken: googleAuth.idToken,
    //   );

    //   return await _auth.signInWithCredential(credential);
    // } catch (e) {
    //   if (kDebugMode) {
    //     print('Error signing in with Google: $e');
    //   }
    //   rethrow;
    // }
    if (kDebugMode) {
      print('Google Sign-In disabled due to dependency issue.');
    }
    return null;
  }
}
