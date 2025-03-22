import 'package:expense_tracker_cipherschool_assignment/models/hive_models/transaction.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/foundation.dart';

class LocalStorageService {
  static const String transactionsBoxName = 'transactions';
  static Box<TransactionModel>? _transactionsBox;

  // Initialize Hive
  static Future<void> initialize() async {
    try {
      final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
      
      // Register adapters
      Hive.registerAdapter(TransactionModelAdapter());
      
      // Open the box
      _transactionsBox = await Hive.openBox<TransactionModel>(transactionsBoxName);
      debugPrint('Hive initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
    }
  }

  // Get all transactions
  static List<TransactionModel> getAllTransactions() {
    try {
      return _transactionsBox?.values.toList() ?? [];
    } catch (e) {
      debugPrint('Error getting transactions from Hive: $e');
      return [];
    }
  }

  // Get transactions for a specific user
  static List<TransactionModel> getUserTransactions(String userId) {
    try {
      return _transactionsBox?.values
          .where((transaction) => transaction.userId == userId)
          .toList() ?? [];
    } catch (e) {
      debugPrint('Error getting user transactions from Hive: $e');
      return [];
    }
  }

  // Get filtered transactions
  static List<TransactionModel> getFilteredTransactions(String userId, DateTime startDate) {
    try {
      return _transactionsBox?.values
          .where((transaction) => 
              transaction.userId == userId && 
              transaction.date.isAfter(startDate))
          .toList() ?? [];
    } catch (e) {
      debugPrint('Error getting filtered transactions from Hive: $e');
      return [];
    }
  }

  // Save a transaction
  static Future<void> saveTransaction(TransactionModel transaction) async {
    try {
      await _transactionsBox?.put(transaction.id, transaction);
    } catch (e) {
      debugPrint('Error saving transaction to Hive: $e');
    }
  }

  // Save multiple transactions
  static Future<void> saveTransactions(List<TransactionModel> transactions) async {
    try {
      Map<String, TransactionModel> transactionsMap = {
        for (var transaction in transactions) transaction.id: transaction
      };
      await _transactionsBox?.putAll(transactionsMap);
    } catch (e) {
      debugPrint('Error saving multiple transactions to Hive: $e');
    }
  }

  // Delete a transaction
  static Future<void> deleteTransaction(String id) async {
    try {
      await _transactionsBox?.delete(id);
    } catch (e) {
      debugPrint('Error deleting transaction from Hive: $e');
    }
  }

  // Get unsynced transactions
  static List<TransactionModel> getUnsyncedTransactions(String userId) {
    try {
      return _transactionsBox?.values
          .where((transaction) => 
              transaction.userId == userId && 
              !transaction.isSynced)
          .toList() ?? [];
    } catch (e) {
      debugPrint('Error getting unsynced transactions from Hive: $e');
      return [];
    }
  }

  // Mark transaction as synced
  static Future<void> markAsSynced(String id) async {
    try {
      TransactionModel? transaction = _transactionsBox?.get(id);
      if (transaction != null) {
        transaction.isSynced = true;
        await _transactionsBox?.put(id, transaction);
      }
    } catch (e) {
      debugPrint('Error marking transaction as synced in Hive: $e');
    }
  }

  // Clear all transactions
  static Future<void> clearAllTransactions() async {
    try {
      await _transactionsBox?.clear();
    } catch (e) {
      debugPrint('Error clearing transactions from Hive: $e');
    }
  }
}