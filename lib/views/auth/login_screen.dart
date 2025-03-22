import 'package:expense_tracker_cipherschool_assignment/styles/styles.dart';
import 'package:expense_tracker_cipherschool_assignment/viewmodels/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

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

    Future<void> _login() async {
      if (_formKey.currentState!.validate()) {
        final user = await authProvider.signInWithEmailAndPassword();
        
        if (user != null && context.mounted) {
          context.go('/home');
        }
      }
    }

    Future<void> _signInWithGoogle() async {
      final user = await authProvider.signInWithGoogle();
      
      if (user != null && context.mounted) {
        context.go('/home');
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Login', style: AppStyles.headingStyle),
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
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
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

                  // Login Button (Full Width)
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
                      onPressed: authProvider.isLoading ? null : _login,
                      child: authProvider.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('Login', style: AppStyles.buttonStyle),
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
            
                  // Google Sign-In Button
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
                      onPressed: authProvider.isLoading ? null : _signInWithGoogle,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/google_logo.png',
                            height: 24,
                            width: 24,
                          ),
                          SizedBox(width: 10),
                          Text('Sign in with Google',
                              style: AppStyles.buttonStyle
                                  .copyWith(color: AppColors.primaryColor)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
            
                  // Don't have an account? Sign Up
                  TextButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () {
                            context.push('/signup');
                          },
                    child: RichText(
                      text: TextSpan(
                        text: 'Don\'t have an account? ',
                        style: AppStyles.bodyStyle.copyWith(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
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