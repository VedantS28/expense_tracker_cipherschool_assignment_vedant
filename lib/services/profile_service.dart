import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:expense_tracker_cipherschool_assignment/models/user.dart';
import 'package:flutter/material.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get current user from Firestore
  Future<UserModel?> getCurrentUser() async {
    if (currentUserId == null) return null;

    DocumentSnapshot doc =
        await _firestore.collection('users').doc(currentUserId).get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }

    return null;
  }

  // Update user profile image
  Future<String?> updateProfileImage(File imageFile) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Upload image to Firebase Storage
      String fileName =
          'profile_${currentUserId}_${DateTime.now().millisecondsSinceEpoch}';
      Reference storageRef = _storage.ref().child('profile_images/$fileName');

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Update user document in Firestore
      await _firestore.collection('users').doc(currentUserId).update({
        'photoUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      debugPrint('Error updating profile image: $e');
      return null;
    }
  }

  // Update user details
  Future<bool> updateUserDetails({String? name}) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    try {
      Map<String, dynamic> updateData = {};
      if (name != null && name.isNotEmpty) {
        updateData['name'] = name;
      }

      if (updateData.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(currentUserId)
            .update(updateData);
      }

      return true;
    } catch (e) {
      debugPrint('Error updating user details: $e');
      return false;
    }
  }
}
