import 'package:expense_tracker_cipherschool_assignment/styles/styles.dart';
import 'package:expense_tracker_cipherschool_assignment/viewmodels/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    
    // Clear form when screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authProvider.nameController.text.isNotEmpty) {
        authProvider.clearForm();
      }
    });
    
    Future<void> _signUpWithEmailAndPassword() async {
      if (_formKey.currentState!.validate()) {
        final user = await authProvider.registerWithEmailAndPassword();
        
        if (user != null && context.mounted) {
          context.go('/home');
        }
      }
    }

    Future<void> _signUpWithGoogle() async {
      final user = await authProvider.signInWithGoogle();
      
      if (user != null && context.mounted) {
        context.go('/home');
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Sign Up', style: AppStyles.headingStyle),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Name Field
                  TextFormField(
                    controller: authProvider.nameController,
                    decoration: AppStyles.textFieldDecoration.copyWith(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
            
                  // Email Field
                  TextFormField(
                    controller: authProvider.emailController,
                    decoration: AppStyles.textFieldDecoration.copyWith(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      } 
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
            
                  // Password Field
                  TextFormField(
                    controller: authProvider.passwordController,
                    obscureText: true,
                    decoration: AppStyles.textFieldDecoration.copyWith(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
            
                  // Display error message if any
                  if (authProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        authProvider.errorMessage!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
            
                  // Terms of Service and Privacy Policy with Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: authProvider.agreedToTerms,
                        activeColor: AppColors.primaryColor,
                        onChanged: (newValue) {
                          authProvider.setAgreedToTerms(newValue ?? false);
                        },
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'By signing up, you agree to the ',
                            style: AppStyles.bodyStyle.copyWith(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: AppStyles.bodyStyle.copyWith(
                                  color: AppColors.primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: AppStyles.bodyStyle.copyWith(
                                  color: AppColors.primaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
            
                  // Sign Up Button (Full Width)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: (authProvider.isLoading || !authProvider.agreedToTerms)
                          ? null
                          : _signUpWithEmailAndPassword,
                      child: authProvider.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('Sign Up', style: AppStyles.buttonStyle),
                    ),
                  ),
                  SizedBox(height: 20),
            
                  // Divider with "Or with"
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('Or with',
                            style: AppStyles.bodyStyle.copyWith(color: Colors.grey)),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
            
                  // Google Sign-Up Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryColor),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: authProvider.isLoading ? null : _signUpWithGoogle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/google_logo.png',
                            height: 24,
                            width: 24,
                          ),
                          SizedBox(width: 10),
                          Text('Sign Up with Google',
                              style: AppStyles.buttonStyle
                                  .copyWith(color: AppColors.primaryColor)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
            
                  // Already have an account? Login
                  TextButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () {
                            context.go('/login');
                          },
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: AppStyles.bodyStyle.copyWith(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: AppStyles.bodyStyle.copyWith(
                              color: AppColors.primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}