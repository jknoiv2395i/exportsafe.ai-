import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'analytics_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AnalyticsService _analytics = AnalyticsService();

  // Future<User?> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) return null;

  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;

  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     final UserCredential userCredential = await _firebaseAuth
  //         .signInWithCredential(credential);

  //     if (userCredential.user != null) {
  //       await _analytics.logLogin('google');
  //       // Check if user exists, if not create profile
  //       final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
  //       if (!userDoc.exists) {
  //         await _firestore.collection('users').doc(userCredential.user!.uid).set({
  //           'email': userCredential.user!.email,
  //           'displayName': userCredential.user!.displayName,
  //           'photoURL': userCredential.user!.photoURL,
  //           'createdAt': FieldValue.serverTimestamp(),
  //           'lastLogin': FieldValue.serverTimestamp(),
  //         });
  //         await _analytics.logSignUp('google');
  //       } else {
  //          // Update last login
  //          await _firestore.collection('users').doc(userCredential.user!.uid).update({
  //           'lastLogin': FieldValue.serverTimestamp(),
  //         });
  //       }
  //     }

  //     return userCredential.user;
  //   } catch (e) {
  //     print('Google Sign-In Error: $e');
  //     await _analytics.logError(e.toString(), 'signInWithGoogle');
  //     return null;
  //   }
  // }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // Update last login
      if (userCredential.user != null) {
        try {
          await _analytics.logLogin('email');
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({'lastLogin': FieldValue.serverTimestamp()});
        } catch (e) {
          print("Error updating user data: $e");
          // Correctly proceed even if analytics fails
        }
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw "Firebase Error (${e.code}): ${e.message}";
    } catch (e) {
      try {
        await _analytics.logError(e.toString(), 'signInWithEmail');
      } catch (_) {}
      throw "Login Failed: $e";
    }
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        try {
          await _analytics.logSignUp('email');
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'email': email,
                'createdAt': FieldValue.serverTimestamp(),
                'displayName': email.split('@')[0], // Default display name
              });
        } catch (e) {
          print("Error creating user data: $e");
        }
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "An unknown error occurred";
    } catch (e) {
      try {
        await _analytics.logError(e.toString(), 'signUpWithEmail');
      } catch (_) {}
      throw "Signup Failed: $e";
    }
  }

  Future<User?> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInAnonymously();

      if (userCredential.user != null) {
        // Create a default profile for the anonymous user so the app works
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        if (!userDoc.exists) {
           await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'email': 'guest@exportsafe.ai',
            'displayName': 'Guest User',
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
            'isAnonymous': true,
          });
          await _analytics.logLogin('anonymous');
        } else {
           await _firestore.collection('users').doc(userCredential.user!.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }
      }
      return userCredential.user;
    } catch (e) {
      print('Anonymous Auth Error: $e');
       await _analytics.logError(e.toString(), 'signInAnonymously');
      return null;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      if (displayName != null) await user.updateDisplayName(displayName);
      if (photoURL != null) await user.updatePhotoURL(photoURL);

      final data = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (displayName != null) data['displayName'] = displayName;
      if (photoURL != null) data['photoURL'] = photoURL;

      await _firestore.collection('users').doc(user.uid).set(data, SetOptions(merge: true));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateNotificationPreference(bool isEnabled) async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'notificationsEnabled': isEnabled,
      }, SetOptions(merge: true));
    }
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }
}
