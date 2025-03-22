import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:expense_tracker_cipherschool_assignment/views/transactions/add_transaction_screen.dart';
import 'package:expense_tracker_cipherschool_assignment/views/budget/budget_list_screen.dart';
import 'package:expense_tracker_cipherschool_assignment/views/main/home_screen.dart';
import 'package:expense_tracker_cipherschool_assignment/views/profile/profile_screen.dart';
import 'package:expense_tracker_cipherschool_assignment/views/about/about_screen.dart';
import 'package:expense_tracker_cipherschool_assignment/constants/category_constants.dart';
import 'package:expense_tracker_cipherschool_assignment/viewmodels/budget_provider.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _bottomNavIndex;

  final List<Widget> _screens = [
    HomeScreen(),
    BudgetListScreen(),
    AboutScreen(),
    ProfileScreen(),
  ];

  final List<IconData> iconList = [
    Icons.home,
    Icons.account_balance_wallet,
    Icons.info_outline,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _bottomNavIndex = widget.initialIndex;
  }

  void _handleFABPressed() {
    // Check if user is on budget tab (index 1)
    if (_bottomNavIndex == 1) {
      _showBudgetOptions();
    } else {
      _showTransactionTypeSelector();
    }
  }

  void _showBudgetOptions() {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Budget',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade50,
                    child: Icon(CategoryHelper.getIcon(ExpenseCategory.all),
                        color: Colors.deepPurple),
                  ),
                  title: Text('Overall Budget'),
                  subtitle: Text('Set a budget for all expenses'),
                  onTap: () {
                    Navigator.pop(context);
                    BudgetListScreen.showAddBudgetDialog(context,
                        initialCategory: ExpenseCategory.all);
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade50,
                    child: Icon(Icons.category_outlined, color: Colors.orange),
                  ),
                  title: Text('Category Budget'),
                  subtitle: Text('Set a budget for a specific category'),
                  onTap: () {
                    Navigator.pop(context);
                    BudgetListScreen.showAddBudgetDialog(context,
                        initialCategory: ExpenseCategory.food);
                  },
                ),
              ],
            ),
          );
        });
  }

  void _showTransactionTypeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _bottomNavIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: _handleFABPressed,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        activeColor: Colors.deepPurple,
        inactiveColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
      ),
    );
  }
}
