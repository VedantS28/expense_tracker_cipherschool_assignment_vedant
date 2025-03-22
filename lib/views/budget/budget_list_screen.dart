import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_cipherschool_assignment/viewmodels/budget_provider.dart';
import 'package:expense_tracker_cipherschool_assignment/viewmodels/transaction_provider.dart';
import 'package:expense_tracker_cipherschool_assignment/models/budget.dart';
import 'package:expense_tracker_cipherschool_assignment/styles/styles.dart';
import 'package:expense_tracker_cipherschool_assignment/constants/category_constants.dart';

class BudgetListScreen extends StatelessWidget {
  // This method needs to be made public so MainScreen can access it
  static void showAddBudgetDialog(BuildContext context,
      {ExpenseCategory initialCategory = ExpenseCategory.all}) {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    // Set initial values in provider
    budgetProvider.setBudgetFormValues(
      amount: 0,
      category: initialCategory,
      timeRange: 'monthly',
      notificationThreshold: 80,
    );

    showDialog(
      context: context,
      builder: (context) => Consumer<BudgetProvider>(
        builder: (context, provider, _) {
          return AlertDialog(
            title: Text('Create New Budget'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Budget Amount (₹)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.currency_rupee),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.deepPurple, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      provider.setBudgetFormAmount(double.tryParse(value) ?? 0);
                    },
                  ),
                  SizedBox(height: 16),

                  // Budget type selector (Overall vs Category)
                  Text('Budget Type',
                      style: TextStyle(color: Colors.grey.shade700)),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: RadioListTile<ExpenseCategory>(
                            title: Text('Overall'),
                            value: ExpenseCategory.all,
                            groupValue: provider.formCategory,
                            onChanged: (value) {
                              provider.setBudgetFormCategory(value!);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<ExpenseCategory>(
                            title: Text('Category'),
                            value: provider.formCategory == ExpenseCategory.all
                                ? ExpenseCategory.food
                                : provider.formCategory,
                            groupValue: provider.formCategory,
                            onChanged: (value) {
                              provider.setBudgetFormCategory(value!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (provider.formCategory != ExpenseCategory.all) ...[
                    SizedBox(height: 16),
                    Text('Select Category',
                        style: TextStyle(color: Colors.grey.shade700)),
                    SizedBox(height: 8),
                    DropdownButtonFormField<ExpenseCategory>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      value: provider.formCategory,
                      items: ExpenseCategory.values
                          .where((c) => c != ExpenseCategory.all)
                          .map((category) {
                        return DropdownMenuItem<ExpenseCategory>(
                          value: category,
                          child: Row(
                            children: [
                              Icon(
                                CategoryHelper.getIcon(category),
                                color: CategoryHelper.getColor(category),
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(CategoryHelper.getName(category)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        provider.setBudgetFormCategory(value!);
                      },
                    ),
                  ],

                  SizedBox(height: 16),
                  Text('Time Range',
                      style: TextStyle(color: Colors.grey.shade700)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    value: provider.formTimeRange,
                    items: [
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(
                          value: 'monthly', child: Text('Monthly')),
                      DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                    ],
                    onChanged: (value) {
                      provider.setBudgetFormTimeRange(value!);
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Notification Threshold',
                      style: TextStyle(color: Colors.grey.shade700)),
                  SizedBox(height: 8),
                  Slider(
                    value: provider.formNotificationThreshold.toDouble(),
                    min: 10,
                    max: 100,
                    divisions: 9,
                    label: '${provider.formNotificationThreshold}%',
                    activeColor: Colors.deepPurple,
                    onChanged: (value) {
                      provider
                          .setBudgetFormNotificationThreshold(value.round());
                    },
                  ),
                  Center(
                    child: Text(
                      'Alert when ${provider.formNotificationThreshold}% of budget is used',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: Text('Create'),
                onPressed: () async {
                  if (provider.formAmount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid amount')),
                    );
                    return;
                  }

                  bool success = await provider.createBudget(
                    amount: provider.formAmount,
                    category: provider.formCategory,
                    timeRange: provider.formTimeRange,
                    notificationThreshold: provider.formNotificationThreshold,
                  );

                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Budget created successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create budget'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the budget provider on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budgetProvider =
          Provider.of<BudgetProvider>(context, listen: false);
      if (!budgetProvider.isInitialized) {
        budgetProvider.initialize();
      }
    });

    final budgetProvider = Provider.of<BudgetProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final budgets = budgetProvider.budgets;
    final isLoading = budgetProvider.isLoading;

    // Currency formatter
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.deepPurple))
            : budgets.isEmpty
                ? _buildEmptyState(context)
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar with profile and notification
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                           
                            Text(
                              'Budget Management',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                           
                          ],
                        ),
                        SizedBox(height: 20),

                        Text(
                          'Your Budgets',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Manage and track your spending limits',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 20),

                        // Category summary widget
                        _buildCategorySummary(
                            context, transactionProvider, currencyFormat),

                        // Tab selector for budget type view
                        Container(
                          height: 40,
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              _buildBudgetTypeTab(context, 'All', 0),
                              _buildBudgetTypeTab(context, 'Category', 1),
                            ],
                          ),
                        ),

                        // Recent Budgets Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Budgets',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                           
                          ],
                        ),
                        SizedBox(height: 10),

                        Expanded(
                          child: ListView.builder(
                            itemCount:
                                budgetProvider.filterBudgetsByType().length,
                            itemBuilder: (context, index) {
                              final budget =
                                  budgetProvider.filterBudgetsByType()[index];

                              // Calculate spending for this budget
                              double totalSpent = _calculateSpentAmount(
                                  transactionProvider,
                                  budget.category,
                                  budget.startDate,
                                  budget.endDate);

                              // Calculate percentage
                              int percentUsed =
                                  ((totalSpent / budget.amount) * 100).round();
                              percentUsed = percentUsed.clamp(0, 100);

                              // Pick color based on percentage
                              Color progressColor = Colors.green;
                              if (percentUsed > 75)
                                progressColor = Colors.red;
                              else if (percentUsed > 50)
                                progressColor = Colors.orange;

                              return _buildBudgetCard(
                                context,
                                budget,
                                totalSpent,
                                percentUsed,
                                progressColor,
                                currencyFormat,
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

  // Budget type tab selector
  Widget _buildBudgetTypeTab(BuildContext context, String title, int index) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    bool isSelected = budgetProvider.selectedBudgetTypeIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          budgetProvider.setSelectedBudgetTypeIndex(index);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFFFF6E5) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.grey,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Build category spending summary
  Widget _buildCategorySummary(BuildContext context,
      TransactionProvider transactionProvider, NumberFormat currencyFormat) {
    // Get spending by category for current month
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    Map<String, double> categorySpending = {};

    // Initialize spending map for all categories
    for (var category in ExpenseCategory.values) {
      if (category != ExpenseCategory.all) {
        categorySpending[category.name] = 0;
      }
    }

    // Calculate spending for each category
    for (var transaction in transactionProvider.transactions) {
      if (transaction['type'] != 'expense') continue;

      // Convert transaction date
      DateTime transactionDate;
      final dateValue = transaction['date'];
      if (dateValue is DateTime) {
        transactionDate = dateValue;
      } else if (dateValue != null) {
        transactionDate = (dateValue as dynamic).toDate();
      } else {
        continue;
      }

      // Check if transaction is in current month
      if (transactionDate.isBefore(startOfMonth) ||
          transactionDate.isAfter(endOfMonth)) {
        continue;
      }

      // Add transaction amount to category total
      final categoryString = transaction['category'] ?? 'other';
      final category = CategoryHelper.fromString(categoryString);
      final amount = (transaction['amount'] as num).toDouble();

      if (category != ExpenseCategory.all) {
        categorySpending[category.name] =
            (categorySpending[category.name] ?? 0) + amount;
      }
    }

    // Remove categories with no spending
    categorySpending.removeWhere((key, value) => value <= 0);

    // Skip if no spending data
    if (categorySpending.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Spending',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          // Show spending by category
          ...categorySpending.entries.map((entry) {
            final categoryEnum = CategoryHelper.fromString(entry.key);
            final spent = entry.value;

            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CategoryHelper.getBackgroundColor(categoryEnum),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(CategoryHelper.getIcon(categoryEnum),
                        color: CategoryHelper.getColor(categoryEnum), size: 16),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      CategoryHelper.getName(categoryEnum),
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    currencyFormat.format(spent),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Empty state widget
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 60,
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'No budgets yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Create a budget to track your spending and stay on top of your finances',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => showAddBudgetDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Create Budget'),
          ),
        ],
      ),
    );
  }

  // Budget card widget
  Widget _buildBudgetCard(
    BuildContext context,
    BudgetModel budget,
    double totalSpent,
    int percentUsed,
    Color progressColor,
    NumberFormat currencyFormat,
  ) {
    // Get styling attributes for this category
    final IconData icon = CategoryHelper.getIcon(budget.category);
    final Color iconColor = CategoryHelper.getColor(budget.category);
    final Color bgColor = CategoryHelper.getBackgroundColor(budget.category);

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
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
                    CategoryHelper.getName(budget.category),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _getTimeRangeText(budget.timeRange),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Budget',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              currencyFormat.format(budget.amount),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Spent',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              currencyFormat.format(totalSpent),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: totalSpent > budget.amount
                                    ? Colors.red
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percentUsed / 100,
                      backgroundColor: Colors.grey.shade200,
                      color: progressColor,
                      minHeight: 6,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$percentUsed% used',
                        style: TextStyle(
                          fontSize: 12,
                          color: progressColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      PopupMenuButton(
                        icon: Icon(Icons.more_vert, size: 18),
                        padding: EdgeInsets.zero,
                        position: PopupMenuPosition.under,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined,
                                    color: Colors.blue, size: 18),
                                SizedBox(width: 8),
                                Text('Edit', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'edit') {
                            _showEditBudgetDialog(context, budget);
                          } else if (value == 'delete') {
                            bool confirm =
                                await _showDeleteConfirmDialog(context);
                            if (confirm) {
                              await Provider.of<BudgetProvider>(context,
                                      listen: false)
                                  .deleteBudget(budget.id);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Calculate amount spent for a specific budget
  double _calculateSpentAmount(TransactionProvider provider,
      ExpenseCategory category, DateTime startDate, DateTime endDate) {
    double total = 0;

    for (var transaction in provider.transactions) {
      if (transaction['type'] != 'expense') continue;

      // Fix the timestamp conversion issue
      DateTime transactionDate;
      final dateValue = transaction['date'];
      if (dateValue is DateTime) {
        transactionDate = dateValue;
      } else if (dateValue != null) {
        // Convert Timestamp to DateTime
        transactionDate = (dateValue as dynamic).toDate();
      } else {
        continue; // Skip if no valid date
      }

      if (transactionDate.isBefore(startDate) ||
          transactionDate.isAfter(endDate)) continue;

      // Convert transaction category to enum
      final transactionCategory =
          CategoryHelper.fromString(transaction['category'] ?? 'other');

      if (category == ExpenseCategory.all || transactionCategory == category) {
        total += (transaction['amount'] as num).toDouble();
      }
    }

    return total;
  }

  // Get readable time range
  String _getTimeRangeText(String timeRange) {
    switch (timeRange) {
      case 'weekly':
        return 'Weekly Budget';
      case 'monthly':
        return 'Monthly Budget';
      case 'yearly':
        return 'Yearly Budget';
      default:
        return 'Budget';
    }
  }

  // Show dialog to edit an existing budget
  void _showEditBudgetDialog(BuildContext context, BudgetModel budget) {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    // Set initial values in provider based on existing budget
    budgetProvider.setBudgetFormValues(
      amount: budget.amount,
      category: budget.category,
      timeRange: budget.timeRange,
      notificationThreshold: budget.notificationThreshold,
    );

    showDialog(
      context: context,
      builder: (context) => Consumer<BudgetProvider>(
        builder: (context, provider, _) {
          return AlertDialog(
            title: Text('Edit Budget'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Budget Amount (₹)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.currency_rupee),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.deepPurple, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                        text: provider.formAmount.toString()),
                    onChanged: (value) {
                      provider.setBudgetFormAmount(double.tryParse(value) ?? 0);
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Category',
                      style: TextStyle(color: Colors.grey.shade700)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<ExpenseCategory>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    value: provider.formCategory,
                    items: [
                      ...ExpenseCategory.values.map((category) {
                        return DropdownMenuItem<ExpenseCategory>(
                          value: category,
                          child: Row(
                            children: [
                              Icon(
                                CategoryHelper.getIcon(category),
                                color: CategoryHelper.getColor(category),
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Text(CategoryHelper.getName(category)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      provider.setBudgetFormCategory(value!);
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Time Range',
                      style: TextStyle(color: Colors.grey.shade700)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    value: provider.formTimeRange,
                    items: [
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(
                          value: 'monthly', child: Text('Monthly')),
                      DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                    ],
                    onChanged: (value) {
                      provider.setBudgetFormTimeRange(value!);
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Notification Threshold',
                      style: TextStyle(color: Colors.grey.shade700)),
                  SizedBox(height: 8),
                  Slider(
                    value: provider.formNotificationThreshold.toDouble(),
                    min: 10,
                    max: 100,
                    divisions: 9,
                    label: '${provider.formNotificationThreshold}%',
                    activeColor: Colors.deepPurple,
                    onChanged: (value) {
                      provider
                          .setBudgetFormNotificationThreshold(value.round());
                    },
                  ),
                  Center(
                    child: Text(
                      'Alert when ${provider.formNotificationThreshold}% of budget is used',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: Text('Update'),
                onPressed: () async {
                  if (provider.formAmount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid amount')),
                    );
                    return;
                  }

                  bool success = await provider.updateBudget(
                    budgetId: budget.id,
                    amount: provider.formAmount,
                    category: provider.formCategory,
                    timeRange: provider.formTimeRange,
                    notificationThreshold: provider.formNotificationThreshold,
                  );

                  if (success) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Budget updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update budget'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // Show confirmation dialog for budget deletion
  Future<bool> _showDeleteConfirmDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Budget?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Text(
                'Are you sure you want to delete this budget? This action cannot be undone.'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ) ??
        false;
  }
}
