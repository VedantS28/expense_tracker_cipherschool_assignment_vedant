import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker_cipherschool_assignment/services/auth_service.dart';

class AuthenticationProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  bool _agreedToTerms = false;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get agreedToTerms => _agreedToTerms;
  
  // Setters with notifications
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void setAgreedToTerms(bool value) {
    _agreedToTerms = value;
    notifyListeners();
  }
  
  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    setErrorMessage(null);
    setAgreedToTerms(false);
  }
  
  // Authentication methods
  Future<User?> signInWithEmailAndPassword() async {
    setLoading(true);
    setErrorMessage(null);
    
    try {
      User? user = await _authService.signInWithEmailAndPassword(
        emailController.text.trim(), 
        passwordController.text.trim()
      );
      return user;
    } catch (e) {
      setErrorMessage(_handleAuthError(e));
      return null;
    } finally {
      setLoading(false);
    }
  }
  
  Future<User?> registerWithEmailAndPassword() async {
    setLoading(true);
    setErrorMessage(null);
    
    try {
      User? user = await _authService.registerWithEmailAndPassword(
        emailController.text.trim(), 
        passwordController.text.trim(), 
        nameController.text.trim()
      );
      return user;
    } catch (e) {
      setErrorMessage(_handleAuthError(e));
      return null;
    } finally {
      setLoading(false);
    }
  }
  
  Future<User?> signInWithGoogle() async {
    setLoading(true);
    setErrorMessage(null);
    
    try {
      User? user = await _authService.signInWithGoogle();
      return user;
    } catch (e) {
      setErrorMessage(_handleAuthError(e));
      return null;
    } finally {
      setLoading(false);
    }
  }
  
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'Email is already in use. Try logging in instead.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password should be at least 6 characters.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many unsuccessful login attempts. Try again later.';
        default:
          return 'Authentication error: ${error.message}';
      }
    }
    return 'An unexpected error occurred.';
  }
}