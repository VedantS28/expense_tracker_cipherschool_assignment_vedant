import 'package:expense_tracker_cipherschool_assignment/viewmodels/transaction_provider.dart';
import 'package:expense_tracker_cipherschool_assignment/viewmodels/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_cipherschool_assignment/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Initialize providers when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUserData();
      Provider.of<TransactionProvider>(context, listen: false).initialize();
    });
  }

  void _handleSignOut() async {
    try {
      await _authService.signOut();
      context.go('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    final user = userProvider.currentUser;
    final isUserLoading = userProvider.isLoading;
    final isTransactionLoading = transactionProvider.isLoading;

    final balance = transactionProvider.balance;
    final totalIncome = transactionProvider.totalIncome;
    final totalExpense = transactionProvider.totalExpense;
    final transactions = transactionProvider.transactions;

    // Format currency with Indian Rupee symbol
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top bar with profile and notification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: isUserLoading
                        ? CircularProgressIndicator()
                        : user?.photoUrl != null
                            ? CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(user!.photoUrl!),
                              )
                            : CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey.shade200,
                                child: Icon(Icons.person, color: Colors.grey),
                              ),
                  ),
                  Row(
                    children: [
                      Text(
                        DateFormat('yyyy').format(DateTime.now()),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      SizedBox(width: 8),
                      Text(DateFormat('MMMM').format(DateTime.now()),
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications_none,
                        color: Colors.deepPurple),
                    onPressed: () => context.push('/notifications'),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Account Balance
              Text(
                'Account Balance',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              SizedBox(height: 8),
              isTransactionLoading
                  ? CircularProgressIndicator()
                  : Text(
                      currencyFormat.format(balance),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              SizedBox(height: 20),

              // Income and Expenses cards
              Row(
                children: [
                  Expanded(
                    child: _buildIncomeCard(
                        totalIncome, isTransactionLoading, currencyFormat),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildExpenseCard(
                        totalExpense, isTransactionLoading, currencyFormat),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Time Filters
              Container(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      4,
                  itemBuilder: (context, index) {
                    final filters = ['Today', 'Week', 'Month', 'Year'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () {
                          transactionProvider.setTimeFilter(filters[index]);
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                transactionProvider.timeFilter == filters[index]
                                    ? Color(0xFFFFF6E5)
                                    : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            filters[index],
                            style: TextStyle(
                              color: transactionProvider.timeFilter ==
                                      filters[index]
                                  ? Colors.orange
                                  : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transaction',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                
                ],
              ),
              SizedBox(height: 10),

              // Recent Transactions List
              isTransactionLoading
                  ? Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : transactions.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Text(
                              'No transactions found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];
                              final isExpense =
                                  transaction['type'] == 'expense';
                              final amount =
                                  (transaction['amount'] as num).toDouble();
                              final category =
                                  transaction['category'] as String;
                              final description =
                                  transaction['description'] as String;
                              final date =
                                  (transaction['date'] as Timestamp).toDate();
                              final timeString =
                                  DateFormat('hh:mm a').format(date);

                              // Determine icon based on category
                              IconData icon;
                              Color bgColor;
                              Color iconColor;

                              if (isExpense) {
                                switch (category.toLowerCase()) {
                                  case 'shopping':
                                    icon = Icons.shopping_bag_outlined;
                                    bgColor = Color(0xFFFFF6E5);
                                    iconColor = Colors.orange;
                                    break;
                                  case 'subscription':
                                    icon = Icons.subscriptions_outlined;
                                    bgColor = Color(0xFFF1ECFF);
                                    iconColor = Colors.deepPurple;
                                    break;
                                  case 'travel':
                                    icon = Icons.directions_car_outlined;
                                    bgColor = Color(0xFFE6F7FF);
                                    iconColor = Colors.blue;
                                    break;
                                  case 'food':
                                    icon = Icons.fastfood_outlined;
                                    bgColor = Color(0xFFFFECEC);
                                    iconColor = Colors.red;
                                    break;
                                  case 'bills':
                                    icon = Icons.receipt_outlined;
                                    bgColor = Color(0xFFE6F7FF);
                                    iconColor = Colors.blue;
                                    break;
                                  default:
                                    icon = Icons.attach_money;
                                    bgColor = Color(0xFFE6F9F0);
                                    iconColor = Colors.green;
                                }
                              } else {
                                switch (category.toLowerCase()) {
                                  case 'salary':
                                    icon = Icons.work_outline;
                                    bgColor = Color(0xFFE6F9F0);
                                    iconColor = Colors.green;
                                    break;
                                  case 'freelance':
                                    icon = Icons.computer;
                                    bgColor = Color(0xFFE6F9F0);
                                    iconColor = Colors.green;
                                    break;
                                  case 'investments':
                                    icon = Icons.trending_up;
                                    bgColor = Color(0xFFE6F9F0);
                                    iconColor = Colors.green;
                                    break;
                                  default:
                                    icon = Icons.attach_money;
                                    bgColor = Color(0xFFE6F9F0);
                                    iconColor = Colors.green;
                                }
                              }

                              return _buildTransactionItem(
                                category,
                                isExpense
                                    ? '- ${currencyFormat.format(amount)}'
                                    : '+ ${currencyFormat.format(amount)}',
                                description,
                                timeString,
                                icon,
                                bgColor,
                                iconColor,
                                isExpense ? Colors.red : Colors.green,
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build income card
  Widget _buildIncomeCard(
      double totalIncome, bool isLoading, NumberFormat format) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFE6F9F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.arrow_downward, color: Colors.green, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Income',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                isLoading
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        format.format(totalIncome),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build expense card
  Widget _buildExpenseCard(
      double totalExpense, bool isLoading, NumberFormat format) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFECEC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.arrow_upward, color: Colors.red, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expenses',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                isLoading
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        format.format(totalExpense),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build transaction items
  Widget _buildTransactionItem(
    String category,
    String amount,
    String description,
    String time,
    IconData icon,
    Color bgColor,
    Color iconColor,
    Color amountColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: amountColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
