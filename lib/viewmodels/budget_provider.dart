import 'package:flutter/foundation.dart';
import 'package:expense_tracker_cipherschool_assignment/models/budget.dart';
import 'package:expense_tracker_cipherschool_assignment/services/budget_service.dart';
import 'package:expense_tracker_cipherschool_assignment/services/notification_service.dart';
import 'package:expense_tracker_cipherschool_assignment/constants/category_constants.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetService _budgetService = BudgetService();
  final NotificationService _notificationService = NotificationService();

  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  int _selectedBudgetTypeIndex = 0;
  bool _isFabExpanded = false;
  bool _isInitialized = false;

  // Form state variables
  double _formAmount = 0;
  ExpenseCategory _formCategory = ExpenseCategory.all;
  String _formTimeRange = 'monthly';
  int _formNotificationThreshold = 80;

  // Getters
  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;
  int get selectedBudgetTypeIndex => _selectedBudgetTypeIndex;
  bool get isFabExpanded => _isFabExpanded;
  bool get isInitialized => _isInitialized;

  // Form getters
  double get formAmount => _formAmount;
  ExpenseCategory get formCategory => _formCategory;
  String get formTimeRange => _formTimeRange;
  int get formNotificationThreshold => _formNotificationThreshold;

  // Setters for UI state
  void setSelectedBudgetTypeIndex(int index) {
    _selectedBudgetTypeIndex = index;
    notifyListeners();
  }

  void toggleFabExpanded() {
    _isFabExpanded = !_isFabExpanded;
    notifyListeners();
  }

  void setFabExpanded(bool value) {
    _isFabExpanded = value;
    notifyListeners();
  }

  // Form state setters
  void setBudgetFormValues({
    required double amount,
    required ExpenseCategory category,
    required String timeRange,
    required int notificationThreshold,
  }) {
    _formAmount = amount;
    _formCategory = category;
    _formTimeRange = timeRange;
    _formNotificationThreshold = notificationThreshold;
    notifyListeners();
  }

  void setBudgetFormAmount(double amount) {
    _formAmount = amount;
    notifyListeners();
  }

  void setBudgetFormCategory(ExpenseCategory category) {
    _formCategory = category;
    notifyListeners();
  }

  void setBudgetFormTimeRange(String timeRange) {
    _formTimeRange = timeRange;
    notifyListeners();
  }

  void setBudgetFormNotificationThreshold(int threshold) {
    _formNotificationThreshold = threshold;
    notifyListeners();
  }

  // Initialize provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _loadBudgets();
    await _notificationService.initialize();

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  // Load all budgets
  Future<void> _loadBudgets() async {
    try {
      _budgets = await _budgetService.getBudgets();
    } catch (e) {
      debugPrint('Error loading budgets: $e');
      _budgets = [];
    }
  }

  // Create a new budget
  Future<bool> createBudget({
    required double amount,
    required ExpenseCategory category,
    required String timeRange,
    required int notificationThreshold,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? budgetId = await _budgetService.createBudget(
        amount: amount,
        category: category,
        timeRange: timeRange,
        notificationThreshold: notificationThreshold,
      );

      if (budgetId != null) {
        await _loadBudgets();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error creating budget: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing budget
  Future<bool> updateBudget({
    required String budgetId,
    double? amount,
    ExpenseCategory? category,
    String? timeRange,
    int? notificationThreshold,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool success = await _budgetService.updateBudget(
        budgetId: budgetId,
        amount: amount,
        category: category,
        timeRange: timeRange,
        notificationThreshold: notificationThreshold,
      );

      if (success) {
        await _loadBudgets();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating budget: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a budget
  Future<bool> deleteBudget(String budgetId) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool success = await _budgetService.deleteBudget(budgetId);

      if (success) {
        await _loadBudgets();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting budget: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter budgets by type (All or Category-specific)
  List<BudgetModel> filterBudgetsByType() {
    if (_selectedBudgetTypeIndex == 0) {
      // All budgets
      return _budgets;
    } else {
      // Only category-specific budgets (exclude "all" category)
      return _budgets.where((b) => b.category != ExpenseCategory.all).toList();
    }
  }

  // Make the notification service accessible for testing
  NotificationService get notificationService => _notificationService;

  // Send a test notification
  Future<void> sendTestNotification() async {
    await _notificationService.showBudgetAlert(
      title: 'Test Budget Alert',
      body:
          'This is a test notification to verify alerts are working properly.',
    );

    // Also log it
    await _notificationService.logBudgetAlert(
      budgetId: 'test-budget-id',
      category: 'test',
      budgetAmount: 1000.0,
      spentAmount: 800.0,
      percentUsed: 80,
    );

    debugPrint('Test notification sent');
  }
}
