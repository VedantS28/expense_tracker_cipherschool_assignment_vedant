import 'package:expense_tracker_cipherschool_assignment/routes/routes.dart';
import 'package:expense_tracker_cipherschool_assignment/services/auth_service.dart';
import 'package:expense_tracker_cipherschool_assignment/services/local_storage_service.dart';
import 'package:expense_tracker_cipherschool_assignment/viewmodels/authentication_provider.dart';
import 'package:expense_tracker_cipherschool_assignment/viewmodels/budget_provider.dart';
import 'package:expense_tracker_cipherschool_assignment/viewmodels/profile_provider.dart';
import 'package:expense_tracker_cipherschool_assignment/viewmodels/transaction_provider.dart';
import 'package:expense_tracker_cipherschool_assignment/viewmodels/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalStorageService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        Provider(create: (_) => AuthService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: appRouter,
    );
  }
}
