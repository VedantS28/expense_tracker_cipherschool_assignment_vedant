import 'package:expense_tracker_cipherschool_assignment/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  // Add this getter to expose the auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // User canceled the sign-in flow
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if this user exists in Firestore
        final userDoc =
            await _firestore.collection(_usersCollection).doc(user.uid).get();

        // If user doesn't exist in Firestore, create a new record
        if (!userDoc.exists) {
          await _saveUserToFirestore(
              uid: user.uid,
              name: user.displayName ?? 'User',
              email: user.email ?? '',
              photoUrl: user.photoURL);
        }
      }

      return user;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in with email and password: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        // Add user to Firestore
        await _saveUserToFirestore(
            uid: user.uid, name: name, email: email, photoUrl: null);

        // Update display name in Firebase Auth
        await user.updateDisplayName(name);
      }

      return user;
    } catch (e) {
      debugPrint('Error registering with email and password: $e');
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Save user to Firestore
  Future<void> _saveUserToFirestore({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    try {
      final UserModel user = UserModel(
        uid: uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
        photoUrl: photoUrl,
      );

      await _firestore.collection(_usersCollection).doc(uid).set(user.toMap());
    } catch (e) {
      debugPrint('Error saving user to Firestore: $e');
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection(_usersCollection).doc(uid).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      rethrow;
    }
  }
}
