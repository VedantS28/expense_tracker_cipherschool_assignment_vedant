import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker_cipherschool_assignment/constants/category_constants.dart';

class BudgetModel {
  final String id;
  final String userId;
  final double amount;
  final ExpenseCategory category; // Using enum instead of string
  final String timeRange; // 'weekly', 'monthly', 'yearly'
  final int notificationThreshold; // Percentage (e.g., 50, 75, 100)
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final bool isNotified; // Track if notification already sent

  BudgetModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.timeRange,
    required this.notificationThreshold,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.isNotified = false, // Default to false
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'category': category.name, // Store enum as string
      'timeRange': timeRange,
      'notificationThreshold': notificationThreshold,
      'startDate': startDate,
      'endDate': endDate,
      'createdAt': createdAt,
      'isNotified': isNotified,
    };
  }

  factory BudgetModel.fromMap(String id, Map<String, dynamic> map) {
    return BudgetModel(
      id: id,
      userId: map['userId'],
      amount: (map['amount'] as num).toDouble(),
      category:
          CategoryHelper.fromString(map['category']), // Convert string to enum
      timeRange: map['timeRange'],
      notificationThreshold: map['notificationThreshold'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isNotified: map['isNotified'] ?? false, // Default to false if not present
    );
  }
}
