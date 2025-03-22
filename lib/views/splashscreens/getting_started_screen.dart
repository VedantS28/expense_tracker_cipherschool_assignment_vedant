import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class GettingStartedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF7B61FF),
              Color(0xFF6A50F0)
            ], // Gradient background
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

            // Welcome Text, Button, and "The best way" text aligned at the bottom
            Positioned(
              bottom: 140, // Adjust this value to align with the button
              left: 30,
              right: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Row containing "Welcome to", "CIPHERX.", and the button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Column for "Welcome to" and "CIPHERX."
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome to',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              fontFamily: 'ABeeZee', // Apply ABeeZee font
                            ),
                          ),
                          const Text(
                            'CIPHERX.',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                              fontFamily:
                                  'Bruno Ace SC', // Apply Bruno Ace SC font
                            ),
                          ),
                        ],
                      ),

                      // Circular button with arrow
                      GestureDetector(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool('isFirstLaunch', false);
                          context.go('/login');
                        },
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            size: 40,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // "The best way" text below the row
                  const SizedBox(height: 10), // Add some spacing
                  const Text(
                    'The best way to track your expenses.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom indicator line
            Positioned(
              bottom: 20,
              left: MediaQuery.of(context).size.width / 2 - 40,
              child: Container(
                width: 80,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
