import 'package:expense_tracker_cipherschool_assignment/viewmodels/transaction_provider.dart';
import 'package:expense_tracker_cipherschool_assignment/constants/category_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum TransactionType { income, expense }

class TransactionScreen extends StatelessWidget {
  final TransactionType type;

  const TransactionScreen({
    Key? key,
    required this.type,
  }) : super(key: key);

  // Get transaction-specific data based on type
  String get _screenTitle => type == TransactionType.income ? 'Income' : 'Expense';
  
  Color get _mainColor => type == TransactionType.income
      ? Color(0xFF8B5CF6)
      : Color(0xFF0D8BFF);
      
  List<String> get _categories {
    if (type == TransactionType.income) {
      return ['Salary', 'Freelance', 'Investments', 'Gift', 'Other'];
    } else {
      // Use the enum values for expense categories
      return ExpenseCategory.values
          .where((c) => c != ExpenseCategory.all)
          .map((c) => CategoryHelper.getName(c))
          .toList();
    }
  }

  String get _currencySymbol => '₹';

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: _mainColor,
      appBar: AppBar(
        backgroundColor: _mainColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _screenTitle,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      // Wrap the Column with SingleChildScrollView to handle keyboard overflow
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight -
              MediaQuery.of(context).padding.top -
              kToolbarHeight,
          child: Column(
            children: [
              // Empty space at the top
              Spacer(),

              // Amount section right above the modal sheet
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How much?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _currencySymbol,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                              contentPadding: EdgeInsets.only(bottom: 4),
                            ),
                            onChanged: (value) {
                              transactionProvider.setAmount(
                                  value.isEmpty ? '0' : value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20), // Space between amount and modal sheet

              // Form section - modal sheet
              Container(
                height: screenHeight * 0.6, // Fixed height for the modal sheet
                padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Category dropdown
                    _buildDropdownField(
                      'Category',
                      transactionProvider.selectedCategory,
                      (value) {
                        transactionProvider.setCategory(value!);
                      },
                      _categories,
                    ),

                    SizedBox(height: 20),

                    // Description field
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[400]!),
                        ),
                      ),
                      onChanged: (value) {
                        transactionProvider.setDescription(value);
                      },
                    ),

                    SizedBox(height: 20),

                    // Wallet dropdown
                    _buildDropdownField(
                      'Wallet',
                      transactionProvider.selectedWallet,
                      (value) {
                        transactionProvider.setWallet(value!);
                      },
                      ['Cash', 'Bank Account', 'Credit Card'],
                    ),

                    Spacer(),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8B5CF6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: transactionProvider.isProcessing
                            ? null
                            : () async {
                                // Validate inputs
                                if (transactionProvider.amount == '0' ||
                                    transactionProvider.selectedCategory.isEmpty ||
                                    transactionProvider.description.isEmpty ||
                                    transactionProvider.selectedWallet.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Please fill all fields')),
                                  );
                                  return;
                                }

                                try {
                                  transactionProvider.setProcessing(true);

                                  bool success;
                                  if (type == TransactionType.income) {
                                    success = await transactionProvider.addIncome(
                                      category: transactionProvider.selectedCategory,
                                      amount: double.parse(transactionProvider.amount),
                                      description: transactionProvider.description,
                                      wallet: transactionProvider.selectedWallet,
                                    );
                                  } else {
                                    success = await transactionProvider.addExpense(
                                      category: transactionProvider.selectedCategory,
                                      amount: double.parse(transactionProvider.amount),
                                      description: transactionProvider.description,
                                      wallet: transactionProvider.selectedWallet,
                                    );
                                  }

                                  if (success) {
                                    // Navigate back if successful
                                    context.pop();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to save transaction')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                } finally {
                                  transactionProvider.setProcessing(false);
                                }
                              },
                        child: transactionProvider.isProcessing
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    Function(String?) onChanged,
    List<String> items,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        suffixIcon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
      ),
      icon: SizedBox.shrink(), // Hide the default dropdown icon
      value: value.isEmpty ? null : value,
      onChanged: onChanged,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      isExpanded: true,
      dropdownColor: Colors.white,
    );
  }
}