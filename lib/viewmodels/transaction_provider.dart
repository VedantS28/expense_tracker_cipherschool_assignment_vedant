import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker_cipherschool_assignment/models/hive_models/transaction.dart';
import 'package:expense_tracker_cipherschool_assignment/services/budget_service.dart';
import 'package:expense_tracker_cipherschool_assignment/services/notification_service.dart';
import 'package:expense_tracker_cipherschool_assignment/services/local_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();
  final BudgetService _budgetService = BudgetService();

  // Connectivity
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;
  bool _isOnline = true;

  String _amount = '0';
  String _selectedCategory = '';
  String _description = '';
  String _selectedWallet = '';
  bool _isProcessing = false;

  String get amount => _amount;
  String get selectedCategory => _selectedCategory;
  String get description => _description;
  String get selectedWallet => _selectedWallet;
  bool get isProcessing => _isProcessing;
  bool get isOnline => _isOnline;

  TransactionProvider() {
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  // Initialize connectivity check
  Future<void> _initConnectivity() async {
    try {
      List<ConnectivityResult> result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      _isOnline = false;
    }
  }

  // Add debug prints for connectivity status
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool wasOnline = _isOnline;
    _isOnline = results.isNotEmpty &&
        results.any((result) => result != ConnectivityResult.none);

    debugPrint(
        '🌐 Connectivity changed: ${wasOnline ? 'Online' : 'Offline'} -> ${_isOnline ? 'Online' : 'Offline'}');

    // If we just came back online, sync data
    if (!wasOnline && _isOnline) {
      debugPrint('🔄 Back online - starting data sync...');
      syncWithFirebase();
    }

    notifyListeners();
  }

  void setAmount(String value) {
    _amount = value;
    notifyListeners();
  }

  void setCategory(String value) {
    _selectedCategory = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setWallet(String value) {
    _selectedWallet = value;
    notifyListeners();
  }

  void setProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }

  void resetTransactionForm() {
    _amount = '0';
    _selectedCategory = '';
    _description = '';
    _selectedWallet = '';
    _isProcessing = false;
    notifyListeners();
  }

  Future<void> checkBudgetThresholds() async {
    try {
      debugPrint('Checking budget thresholds...');
      List<Map<String, dynamic>> alerts =
          await _budgetService.checkBudgetThresholds();

      debugPrint('Found ${alerts.length} budget alerts');
      for (var alert in alerts) {
        // Create notification for each threshold alert
        String categoryName = alert['category'] == 'all'
            ? 'Overall'
            : alert['category'].toString().toUpperCase();
        String timeRange = alert['timeRange'] ?? 'budget';
        int percentUsed = alert['percentUsed'] ?? 0;
        double budgetAmount =
            (alert['budgetAmount'] as num?)?.toDouble() ?? 0.0;
        double spentAmount = (alert['spentAmount'] as num?)?.toDouble() ?? 0.0;

        String title = 'Budget Alert: $categoryName';
        String body = '';

        if (percentUsed >= 100) {
          body =
              'You have exceeded your $timeRange budget for $categoryName! (₹${spentAmount.toInt()} of ₹${budgetAmount.toInt()})';
        } else {
          body =
              'You have used $percentUsed% of your $timeRange budget for $categoryName. (₹${spentAmount.toInt()} of ₹${budgetAmount.toInt()})';
        }

        debugPrint('Showing notification: $title - $body');

        // Show notification
        await _notificationService.showBudgetAlert(
          title: title,
          body: body,
        );

        // Log alert to history
        await _notificationService.logBudgetAlert(
          budgetId: alert['budgetId'] ?? '',
          category: alert['category'] ?? '',
          budgetAmount: budgetAmount,
          spentAmount: spentAmount,
          percentUsed: percentUsed,
        );
      }
    } catch (e) {
      debugPrint('Error checking budget thresholds: $e');
    }
  }

  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String _timeFilter = 'Month'; // Default filter
  double _balance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;

  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String get timeFilter => _timeFilter;
  double get balance => _balance;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;

  // Initialize and load transactions
  Future<void> initialize() async {
    if (_auth.currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    await _loadTransactions();

    _isLoading = false;
    notifyListeners();
  }

  // Set time filter and reload transactions
  Future<void> setTimeFilter(String filter) async {
    if (_timeFilter == filter) return;

    _timeFilter = filter;
    _isLoading = true;
    notifyListeners();

    await _loadTransactions();

    _isLoading = false;
    notifyListeners();
  }

  // Add debug prints for transaction loading
  Future<void> _loadTransactions() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint('❌ No user logged in, can\'t load transactions');
        return;
      }

      // Calculate date range based on filter
      DateTime startDate;
      final now = DateTime.now();

      switch (_timeFilter) {
        case 'Today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'Week':
          startDate = now.subtract(Duration(days: 7));
          break;
        case 'Month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'Year':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(now.year, now.month, 1);
      }

      debugPrint(
          '📅 Loading transactions with filter: $_timeFilter (from ${startDate.toString()})');

      if (_isOnline) {
        debugPrint(
            '📲 Online mode: Loading from Firebase and syncing to local');
        // If online, load from Firebase and sync to local
        await _loadFromFirebaseAndSync(userId, startDate);
      } else {
        debugPrint('📴 Offline mode: Loading from local storage');
        // If offline, load from local storage
        _loadFromLocalStorage(userId, startDate);
      }

      // Calculate totals
      _calculateTotals();
      debugPrint(
          '💰 Calculated totals: Income: $_totalIncome, Expense: $_totalExpense, Balance: $_balance');
    } catch (e) {
      debugPrint('❌ Error loading transactions: $e');
      _transactions = [];
      _totalIncome = 0;
      _totalExpense = 0;
      _balance = 0;
    }
  }

  // Add debug prints for Firebase loading
  Future<void> _loadFromFirebaseAndSync(
      String userId, DateTime startDate) async {
    try {
      debugPrint(
          '🔍 Querying Firebase for transactions since ${startDate.toString()}');

      // Query transactions collection
      QuerySnapshot snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .orderBy('date', descending: true)
          .get();

      debugPrint('✅ Firebase returned ${snapshot.docs.length} transactions');

      // Convert to transaction models and save to local storage
      List<TransactionModel> transactionModels = snapshot.docs.map((doc) {
        return TransactionModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Save to local storage
      debugPrint(
          '💾 Saving ${transactionModels.length} transactions to local storage');
      await LocalStorageService.saveTransactions(transactionModels);

      // Convert to map for UI display
      _transactions = transactionModels.map((model) => model.toMap()).toList();
    } catch (e) {
      debugPrint('❌ Error loading from Firebase: $e');
      debugPrint('⚠️ Falling back to local storage');
      // Fallback to local storage if Firebase query fails
      _loadFromLocalStorage(userId, startDate);
    }
  }

  // Add debug prints for local storage loading
  void _loadFromLocalStorage(String userId, DateTime startDate) {
    try {
      debugPrint(
          '🔍 Querying local storage for transactions since ${startDate.toString()}');

      List<TransactionModel> localTransactions =
          LocalStorageService.getFilteredTransactions(userId, startDate);

      debugPrint(
          '✅ Local storage returned ${localTransactions.length} transactions');

      // Sort by date (descending)
      localTransactions.sort((a, b) => b.date.compareTo(a.date));

      // Convert to map for UI display
      _transactions = localTransactions.map((model) => model.toMap()).toList();
    } catch (e) {
      debugPrint('❌ Error loading from local storage: $e');
      _transactions = [];
    }
  }

  // Add debug prints for syncing
  Future<void> syncWithFirebase() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint('❌ No user logged in, can\'t sync transactions');
        return;
      }

      // Get unsynced transactions
      List<TransactionModel> unsyncedTransactions =
          LocalStorageService.getUnsyncedTransactions(userId);

      debugPrint(
          '🔄 Found ${unsyncedTransactions.length} unsynced transactions to sync with Firebase');

      int syncedCount = 0;
      int failedCount = 0;

      for (var transaction in unsyncedTransactions) {
        try {
          debugPrint(
              '🔄 Syncing transaction ${transaction.id} (${transaction.type}: ${transaction.amount})');

          // Add to Firebase
          if (transaction.id.startsWith('local_')) {
            // This is a new transaction created while offline
            debugPrint('📤 Uploading new local transaction to Firebase');
            DocumentReference docRef = await _firestore
                .collection('transactions')
                .add(transaction.toFirestore());

            // Update local ID with Firebase ID
            String newId = docRef.id;
            debugPrint('✅ Firebase assigned ID: $newId');

            // Delete old local transaction
            await LocalStorageService.deleteTransaction(transaction.id);
            debugPrint('🗑️ Deleted local transaction: ${transaction.id}');

            // Create new transaction with Firebase ID
            TransactionModel updatedTransaction = TransactionModel(
              id: newId,
              userId: transaction.userId,
              type: transaction.type,
              category: transaction.category,
              amount: transaction.amount,
              description: transaction.description,
              wallet: transaction.wallet,
              date: transaction.date,
              isSynced: true,
            );

            // Save updated transaction
            await LocalStorageService.saveTransaction(updatedTransaction);
            debugPrint('💾 Saved updated transaction with Firebase ID');
          } else {
            // This is an existing transaction that was modified offline
            debugPrint('📤 Updating existing transaction in Firebase');
            await _firestore
                .collection('transactions')
                .doc(transaction.id)
                .set(transaction.toFirestore());

            // Mark as synced
            await LocalStorageService.markAsSynced(transaction.id);
            debugPrint('✓ Marked transaction as synced: ${transaction.id}');
          }

          syncedCount++;
        } catch (e) {
          debugPrint('❌ Error syncing transaction ${transaction.id}: $e');
          failedCount++;
        }
      }

      debugPrint('🔄 Sync complete: $syncedCount synced, $failedCount failed');

      // Refresh transactions
      debugPrint('🔄 Refreshing transactions after sync');
      await initialize();
    } catch (e) {
      debugPrint('❌ Error syncing with Firebase: $e');
    }
  }

  // Calculate income, expense and balance
  void _calculateTotals() {
    _totalIncome = 0;
    _totalExpense = 0;

    for (var transaction in _transactions) {
      final amount = (transaction['amount'] as num).toDouble();
      if (transaction['type'] == 'income') {
        _totalIncome += amount;
      } else {
        _totalExpense += amount;
      }
    }

    _balance = _totalIncome - _totalExpense;
  }

  // Debug prints for add transaction methods
  Future<bool> addIncome({
    required String category,
    required double amount,
    required String description,
    required String wallet,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint('❌ No user logged in, can\'t add income');
        return false;
      }

      debugPrint(
          '💰 Adding income transaction (${_isOnline ? 'Online' : 'Offline'}): $amount $category');

      String transactionId;
      bool isSynced = _isOnline;

      if (_isOnline) {
        // Create new transaction document in Firebase
        debugPrint('📤 Creating transaction in Firebase');
        DocumentReference docRef =
            await _firestore.collection('transactions').add({
          'userId': userId,
          'type': 'income',
          'category': category,
          'amount': amount,
          'description': description,
          'wallet': wallet,
          'date': DateTime.now(),
        });
        transactionId = docRef.id;
        debugPrint('✅ Firebase assigned ID: $transactionId');
      } else {
        // Create local ID if offline
        transactionId = 'local_${const Uuid().v4()}';
        debugPrint('📱 Created local ID: $transactionId (will sync later)');
      }

      // Create transaction model
      TransactionModel transaction = TransactionModel(
        id: transactionId,
        userId: userId,
        type: 'income',
        category: category,
        amount: amount,
        description: description,
        wallet: wallet,
        date: DateTime.now(),
        isSynced: isSynced,
      );

      // Save to local storage
      await LocalStorageService.saveTransaction(transaction);

      // Reload transactions to update UI
      await initialize();
      return true;
    } catch (e) {
      debugPrint('Error adding income: $e');
      return false;
    }
  }

  // Add new expense transaction
  Future<bool> addExpense({
    required String category,
    required double amount,
    required String description,
    required String wallet,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      String transactionId;
      bool isSynced = _isOnline;

      if (_isOnline) {
        // Create new transaction document in Firebase
        DocumentReference docRef =
            await _firestore.collection('transactions').add({
          'userId': userId,
          'type': 'expense',
          'category': category,
          'amount': amount,
          'description': description,
          'wallet': wallet,
          'date': DateTime.now(),
        });
        transactionId = docRef.id;
      } else {
        // Create local ID if offline
        transactionId = 'local_${const Uuid().v4()}';
      }

      // Create transaction model
      TransactionModel transaction = TransactionModel(
        id: transactionId,
        userId: userId,
        type: 'expense',
        category: category,
        amount: amount,
        description: description,
        wallet: wallet,
        date: DateTime.now(),
        isSynced: isSynced,
      );

      // Save to local storage
      await LocalStorageService.saveTransaction(transaction);

      // Reload transactions to update UI
      await initialize();

      // Check budget thresholds if online
      if (_isOnline) {
        await checkBudgetThresholds();
      }

      return true;
    } catch (e) {
      debugPrint('Error adding expense: $e');
      return false;
    }
  }
}
