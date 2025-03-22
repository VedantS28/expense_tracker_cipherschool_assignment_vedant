import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.photoUrl,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': createdAt,
      'photoUrl': photoUrl,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      photoUrl: map['photoUrl'],
    );
  }
}