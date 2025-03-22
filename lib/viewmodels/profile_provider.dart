import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expense_tracker_cipherschool_assignment/services/profile_service.dart';
import 'package:expense_tracker_cipherschool_assignment/services/auth_service.dart';

class ProfileProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();
  
  bool _isUploading = false;
  bool get isUploading => _isUploading;

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<String?> pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image == null) return null;

      _isUploading = true;
      notifyListeners();

      File imageFile = File(image.path);
      
      // Upload image using profile service
      String? photoUrl = await _profileService.updateProfileImage(imageFile);
      
      return photoUrl;
    } catch (e) {
      throw e;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}