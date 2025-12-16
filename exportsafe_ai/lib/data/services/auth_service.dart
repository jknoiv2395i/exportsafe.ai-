import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'analytics_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AnalyticsService _analytics = AnalyticsService();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      if (userCredential.user != null) {
        await _analytics.logLogin('google');
        // Check if user exists, if not create profile
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'email': userCredential.user!.email,
            'displayName': userCredential.user!.displayName,
            'photoURL': userCredential.user!.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          });
          await _analytics.logSignUp('google');
        } else {
           // Update last login
           await _firestore.collection('users').doc(userCredential.user!.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential.user;
    } catch (e) {
      print('Google Sign-In Error: $e');
      await _analytics.logError(e.toString(), 'signInWithGoogle');
      return null;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      
      // Update last login
      if (userCredential.user != null) {
         await _analytics.logLogin('email');
         await _firestore.collection('users').doc(userCredential.user!.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
         }).catchError((e) => print("Error updating last login: $e")); 
      }

      return userCredential.user;
    } catch (e) {
      print('Email Sign-In Error: $e');
      await _analytics.logError(e.toString(), 'signInWithEmail');
      return null;
    }
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      
      if (userCredential.user != null) {
        await _analytics.logSignUp('email');
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'displayName': email.split('@')[0], // Default display name
        });
      }

      return userCredential.user;
    } catch (e) {
      print('Sign-Up Error: $e');
      await _analytics.logError(e.toString(), 'signUpWithEmail');
      return null;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }
}
