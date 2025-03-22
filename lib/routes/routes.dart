import 'package:expense_tracker_cipherschool_assignment/services/auth_service.dart';
import 'package:expense_tracker_cipherschool_assignment/views/budget/budget_list_screen.dart';
import 'package:expense_tracker_cipherschool_assignment/views/main/home_screen.dart';
import 'package:expense_tracker_cipherschool_assignment/views/auth/login_screen.dart';
import 'package:expense_tracker_cipherschool_assignment/views/main/main_screen.dart';
import 'package:expense_tracker_cipherschool_assignment/views/notification/notification_screen.dart';
import 'package:expense_tracker_cipherschool_assignment/views/auth/signup_screen.dart';
import 'package:expense_tracker_cipherschool_assignment/views/splashscreens/getting_started_screen.dart';
import 'package:expense_tracker_cipherschool_assignment/views/splashscreens/splash_screen.dart';
import 'package:expense_tracker_cipherschool_assignment/views/transactions/transaction_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    // Check if it's a subsequent launch
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    // If not first launch, skip splash and go directly to login or home
    if (!isFirstLaunch && state.uri.path == '/') {
      bool isAuthenticated = FirebaseAuth.instance.currentUser != null;
      if (isAuthenticated) {
        return '/home';
      } else {
        return '/login';
      }
    }

    return null; // No redirect for other cases
  },
  routes: [
    // Splash Screen Route
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreen(),
    ),

    // Getting Started Screen Route
    GoRoute(
      path: '/getting-started',
      builder: (context, state) => GettingStartedScreen(),
    ),

    // Login Screen Route
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),

    // Signup Screen Route
    GoRoute(
      path: '/signup',
      builder: (context, state) => SignupScreen(),
    ),

    // Home Screen Route (Main Screen)
    GoRoute(
      path: '/home',
      builder: (context, state) => MainScreen(),
      redirect: (context, state) {
        bool isAuthenticated = FirebaseAuth.instance.currentUser != null;
        if (!isAuthenticated) {
          return '/login';
        }
        return null; // No redirect
      },
    ),

    // Income Transaction Screen Route
    GoRoute(
      path: '/income/new',
      builder: (context, state) =>
          TransactionScreen(type: TransactionType.income),
    ),

    // Expense Transaction Screen Route
    GoRoute(
      path: '/expense/new',
      builder: (context, state) =>
          TransactionScreen(type: TransactionType.expense),
    ),

    // Budget List Screen Route
    GoRoute(
      path: '/budgets',
      builder: (context, state) => BudgetListScreen(),
    ),

    // Notification Screen Route
    GoRoute(
      path: '/notifications',
      builder: (context, state) => NotificationScreen(),
    ),
  ],
);
