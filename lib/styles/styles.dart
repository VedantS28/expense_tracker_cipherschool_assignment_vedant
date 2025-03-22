import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color accentColor = Color(0xFF03DAC5);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF000000);
  static const Color buttonColor = Color(0xFF6200EE);
  static const Color errorColor = Color(0xFFB00020);
}

class AppStyles {
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: AppColors.textColor,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const InputDecoration textFieldDecoration = InputDecoration(
    border: OutlineInputBorder(),
    labelStyle: TextStyle(color: AppColors.textColor),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.primaryColor),
    ),
  );
}