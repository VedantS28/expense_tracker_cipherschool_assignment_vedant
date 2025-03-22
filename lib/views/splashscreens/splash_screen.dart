import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate a 2-second delay

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      // Navigate to Getting Started Screen
      if (mounted) {
        context.go('/getting-started');
      }
    } else {
      // Navigate to Login Screen
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF7B61FF), // Gradient color 1
              Color(0xFF6A50F0), // Gradient color 2
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Logo at the top-left
            Positioned(
              top: 50,
              left: 20,
              child: Image.asset(
                'assets/logo.png', // Replace with your logo asset
                width: 60,
                height: 60,
              ),
            ),

            // Circular pattern at the top-right (1/4 visible)
            Positioned(
              top: 50, // Adjust to show only 1/4 of the circle
              right: -20,
              child: Image.asset(
                'assets/top_right_circle.png', // Replace with your circle image asset
                width: 200,
                height: 200,
              ),
            ),

            // Circular pattern at the bottom-left (1/4 visible)
            Positioned(
              bottom: 30, // Adjust to show only 1/4 of the circle
              left: -20,
              child: Image.asset(
                'assets/bottom_left_circle.png', // Replace with your circle image asset
                width: 200,
                height: 200,
              ),
            ),

            // Centered content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CIPHERX',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White color for the main text
                    ),
                  ),
                  SizedBox(height: 10), // Adjust spacing as needed
                  Text(
                    'By',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white
                          .withOpacity(0.8), // Semi-transparent white
                    ),
                  ),
                ],
              ),
            ),

            // "Open Source Community" at the bottom
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'by Open Source ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: 'Community',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFF8A401), // Yellowish color only for "Community"
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
