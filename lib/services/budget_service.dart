import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker_cipherschool_assignment/models/budget.dart';
import 'package:expense_tracker_cipherschool_assignment/constants/category_constants.dart';
import 'package:flutter/material.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all budgets for current user
  Future<List<BudgetModel>> getBudgets() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) =>
              BudgetModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting budgets: $e');
      return [];
    }
  }

  // Create a new budget
  Future<String?> createBudget({
    required double amount,
    required ExpenseCategory category,
    required String timeRange,
    required int notificationThreshold,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    try {
      // Calculate start and end dates based on time range
      DateTime now = DateTime.now();
      DateTime startDate = DateTime(now.year, now.month, now.day);
      DateTime endDate;

      switch (timeRange) {
        case 'weekly':
          // End date is 7 days from now
          endDate = startDate.add(const Duration(days: 7));
          break;
        case 'monthly':
          // End date is the last day of current month
          endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case 'yearly':
          // End date is the last day of current year
          endDate = DateTime(now.year + 1, 1, 0);
          break;
        default:
          // Default to monthly
          endDate = DateTime(now.year, now.month + 1, 0);
      }

      // Create new budget document
      DocumentReference docRef = await _firestore.collection('budgets').add({
        'userId': userId,
        'amount': amount,
        'category': category.name, 
        'timeRange': timeRange,
        'notificationThreshold': notificationThreshold,
        'startDate': startDate,
        'endDate': endDate,
        'createdAt': FieldValue.serverTimestamp(),
        'isNotified': false, 
      });

      return docRef.id;
    } catch (e) {
      debugPrint('Error creating budget: $e');
      return null;
    }
  }

  // Update existing budget
  Future<bool> updateBudget({
    required String budgetId,
    double? amount,
    ExpenseCategory? category,
    String? timeRange,
    int? notificationThreshold,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'isNotified': false, // Reset notification flag when budget is updated
      };

      if (amount != null) updateData['amount'] = amount;
      if (category != null) updateData['category'] = category.name;
      if (notificationThreshold != null)
        updateData['notificationThreshold'] = notificationThreshold;

      if (timeRange != null) {
        updateData['timeRange'] = timeRange;

        // Recalculate end date if time range changes
        DateTime now = DateTime.now();
        DateTime startDate = DateTime(now.year, now.month, now.day);
        DateTime endDate;

        switch (timeRange) {
          case 'weekly':
            endDate = startDate.add(const Duration(days: 7));
            break;
          case 'monthly':
            endDate = DateTime(now.year, now.month + 1, 0);
            break;
          case 'yearly':
            endDate = DateTime(now.year + 1, 1, 0);
            break;
          default:
            endDate = DateTime(now.year, now.month + 1, 0);
        }

        updateData['startDate'] = startDate;
        updateData['endDate'] = endDate;
      }

      await _firestore.collection('budgets').doc(budgetId).update(updateData);
      return true;
    } catch (e) {
      debugPrint('Error updating budget: $e');
      return false;
    }
  }

  // Delete a budget
  Future<bool> deleteBudget(String budgetId) async {
    try {
      await _firestore.collection('budgets').doc(budgetId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting budget: $e');
      return false;
    }
  }

  // Mark a budget as notified
  Future<bool> markBudgetAsNotified(String budgetId) async {
    try {
      await _firestore.collection('budgets').doc(budgetId).update({
        'isNotified': true,
      });
      return true;
    } catch (e) {
      debugPrint('Error marking budget as notified: $e');
      return false;
    }
  }

  // Check if any budget thresholds have been reached
  Future<List<Map<String, dynamic>>> checkBudgetThresholds() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    try {
      debugPrint("Starting budget threshold check");

      // Get active budgets
      final QuerySnapshot budgetSnapshot = await _firestore
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .where('endDate', isGreaterThanOrEqualTo: DateTime.now())
          .get();

      debugPrint("Found ${budgetSnapshot.docs.length} active budgets");
      List<Map<String, dynamic>> thresholdAlerts = [];

      for (var budgetDoc in budgetSnapshot.docs) {
        final budget = BudgetModel.fromMap(
            budgetDoc.id, budgetDoc.data() as Map<String, dynamic>);

        // Skip already notified budgets
        if (budget.isNotified) {
          debugPrint("Budget ${budget.id} already notified. Skipping.");
          continue;
        }

        debugPrint(
            "Checking budget: ${budget.id} - Category: ${budget.category} - Threshold: ${budget.notificationThreshold}%");

        // Get all expenses within the budget time period
        QuerySnapshot expenseSnapshot = await _firestore
            .collection('transactions')
            .where('userId', isEqualTo: userId)
            .where('type', isEqualTo: 'expense')
            .where('date', isGreaterThanOrEqualTo: budget.startDate)
            .where('date', isLessThanOrEqualTo: budget.endDate)
            .get();

        debugPrint(
            "Found ${expenseSnapshot.docs.length} expenses in this time period");

        // Calculate spending based on category
        double totalSpent = 0;
        for (var expenseDoc in expenseSnapshot.docs) {
          Map<String, dynamic> expense =
              expenseDoc.data() as Map<String, dynamic>;

          // Convert transaction category to enum for proper comparison
          final String categoryStr = expense['category'] ?? 'other';

          // Use CategoryHelper to convert string to enum
          final ExpenseCategory expenseCategory =
              CategoryHelper.fromString(categoryStr);

          // Match if budget is for all categories or matches the expense category
          if (budget.category == ExpenseCategory.all ||
              budget.category == expenseCategory) {
            totalSpent += (expense['amount'] as num).toDouble();
          }
        }

        debugPrint(
            "Total spent for this budget: $totalSpent of ${budget.amount}");

        // Calculate percentage of budget used
        int percentUsed = budget.amount > 0
            ? ((totalSpent / budget.amount) * 100).round()
            : 0;

        debugPrint(
            "Percent used: $percentUsed% (Threshold: ${budget.notificationThreshold}%)");

        // Check if threshold has been reached or exceeded
        if (percentUsed >= budget.notificationThreshold) {
          debugPrint("THRESHOLD EXCEEDED! Adding alert");
          thresholdAlerts.add({
            'budgetId': budget.id,
            'category': budget.category.name,
            'timeRange': budget.timeRange,
            'budgetAmount': budget.amount,
            'spentAmount': totalSpent,
            'percentUsed': percentUsed,
            'thresholdPercentage': budget.notificationThreshold,
          });

          // Mark this budget as notified
          await markBudgetAsNotified(budget.id);
        } else {
          debugPrint("Threshold not exceeded. No alert needed.");
        }
      }

      debugPrint("Returning ${thresholdAlerts.length} threshold alerts");
      return thresholdAlerts;
    } catch (e) {
      debugPrint('Error checking budget thresholds: $e');
      return [];
    }
  }
}
