import 'dart:io';
import 'package:flutter/material.dart';
import 'package:expense_tracker_cipherschool_assignment/models/user.dart';
import 'package:expense_tracker_cipherschool_assignment/services/profile_service.dart';

class UserProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // Initialize user data
  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _profileService.getCurrentUser();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update profile image
  Future<bool> updateProfileImage(File imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? photoUrl = await _profileService.updateProfileImage(imageFile);

      if (photoUrl != null && _currentUser != null) {
        _currentUser = UserModel(
          uid: _currentUser!.uid,
          name: _currentUser!.name,
          email: _currentUser!.email,
          createdAt: _currentUser!.createdAt,
          photoUrl: photoUrl,
        );

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error in provider while updating profile image: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user details
  Future<bool> updateUserDetails({String? name}) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool success = await _profileService.updateUserDetails(name: name);

      if (success && name != null && _currentUser != null) {
        _currentUser = UserModel(
          uid: _currentUser!.uid,
          name: name,
          email: _currentUser!.email,
          createdAt: _currentUser!.createdAt,
          photoUrl: _currentUser!.photoUrl,
        );
      }

      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Error in provider while updating user details: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
