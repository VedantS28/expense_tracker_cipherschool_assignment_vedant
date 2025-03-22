import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  transport,
  entertainment,
  shopping,
  bills,
  subscription,
  other,
  all // Special case for overall budget
}

class CategoryHelper {
  // Convert enum to string
  static String getName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.bills:
        return 'Bills';
      case ExpenseCategory.subscription:
        return 'Subscription';
      case ExpenseCategory.other:
        return 'Other';
      case ExpenseCategory.all:
        return 'Overall';
    }
  }

  // Convert string to enum
  static ExpenseCategory fromString(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'food':
        return ExpenseCategory.food;
      case 'transport':
        return ExpenseCategory.transport;
      case 'entertainment':
        return ExpenseCategory.entertainment;
      case 'shopping':
        return ExpenseCategory.shopping;
      case 'bills':
        return ExpenseCategory.bills;
      case 'subscription':
        return ExpenseCategory.subscription;
      case 'other':
        return ExpenseCategory.other;
      case 'all':
      case 'overall':
        return ExpenseCategory.all;
      default:
        return ExpenseCategory.other;
    }
  }

  // Get icon for category
  static IconData getIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.fastfood_outlined;
      case ExpenseCategory.transport:
        return Icons.directions_car_outlined;
      case ExpenseCategory.entertainment:
        return Icons.movie_outlined;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag_outlined;
      case ExpenseCategory.bills:
        return Icons.receipt_outlined;
      case ExpenseCategory.subscription:
        return Icons.subscriptions_outlined;
      case ExpenseCategory.other:
        return Icons.more_horiz;
      case ExpenseCategory.all:
        return Icons.account_balance_wallet_outlined;
    }
  }

  // Get color for category
  static Color getColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.red;
      case ExpenseCategory.transport:
        return Colors.blue;
      case ExpenseCategory.entertainment:
        return Colors.purple;
      case ExpenseCategory.shopping:
        return Colors.orange;
      case ExpenseCategory.bills:
        return Colors.teal;
      case ExpenseCategory.subscription:
        return Colors.deepPurple;
      case ExpenseCategory.other:
        return Colors.grey;
      case ExpenseCategory.all:
        return Colors.green;
    }
  }

  // Get background color for category
  static Color getBackgroundColor(ExpenseCategory category) {
    Color baseColor = getColor(category);
    return baseColor.withOpacity(0.12);
  }

  // Get all categories as dropdown items
  static List<DropdownMenuItem<String>> getDropdownItems(
      {bool includeAll = true}) {
    List<DropdownMenuItem<String>> items = [];

    if (includeAll) {
      items.add(DropdownMenuItem(
        value: ExpenseCategory.all.name,
        child: Text(getName(ExpenseCategory.all)),
      ));
    }

    // Add all categories except 'all'
    ExpenseCategory.values
        .where((c) => c != ExpenseCategory.all)
        .forEach((category) {
      items.add(DropdownMenuItem(
        value: category.name,
        child: Text(getName(category)),
      ));
    });

    return items;
  }
}
