import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker_cipherschool_assignment/models/expense.dart';
import 'package:expense_tracker_cipherschool_assignment/models/income.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Add expense transaction
  Future<void> addExpense({
    required String category,
    required double amount,
    required String description,
    required String wallet,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _firestore.collection('expenses').add({
      'userId': currentUserId,
      'category': category,
      'amount': amount,
      'description': description,
      'wallet': wallet,
      'date': Timestamp.now(),
    });
  }

  // Add income transaction
  Future<void> addIncome({
    required String category,
    required double amount,
    required String description,
    required String wallet,
  }) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    await _firestore.collection('incomes').add({
      'userId': currentUserId,
      'category': category,
      'amount': amount,
      'description': description,
      'wallet': wallet,
      'date': Timestamp.now(),
    });
  }

  // Get expenses for the current user with time filter
  Stream<QuerySnapshot> getExpenses(String timeFilter) {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    DateTime startDate = _getStartDateFromFilter(timeFilter);
    
    return _firestore
        .collection('expenses')
        .where('userId', isEqualTo: currentUserId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Get incomes for the current user with time filter
  Stream<QuerySnapshot> getIncomes(String timeFilter) {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    DateTime startDate = _getStartDateFromFilter(timeFilter);
    
    return _firestore
        .collection('incomes')
        .where('userId', isEqualTo: currentUserId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Get all transactions (combined expenses and incomes) for the current user
  Stream<List<Map<String, dynamic>>> getAllTransactions(String timeFilter) {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final expensesStream = getExpenses(timeFilter);
    final incomesStream = getIncomes(timeFilter);

    return Rx.combineLatest2(
      expensesStream,
      incomesStream,
      (QuerySnapshot expensesSnapshot, QuerySnapshot incomesSnapshot) {
        List<Map<String, dynamic>> allTransactions = [];
        
        // Add expenses
        for (var doc in expensesSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          allTransactions.add({
            'id': doc.id,
            'type': 'expense',
            ...data,
          });
        }
        
        // Add incomes
        for (var doc in incomesSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          allTransactions.add({
            'id': doc.id,
            'type': 'income',
            ...data,
          });
        }
        
        // Sort by date (newest first)
        allTransactions.sort((a, b) {
          Timestamp aDate = a['date'] as Timestamp;
          Timestamp bDate = b['date'] as Timestamp;
          return bDate.compareTo(aDate);
        });
        
        return allTransactions;
      },
    );
  }

  // Calculate total income for the time period
  Future<double> getTotalIncome(String timeFilter) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    DateTime startDate = _getStartDateFromFilter(timeFilter);
    
    QuerySnapshot snapshot = await _firestore
        .collection('incomes')
        .where('userId', isEqualTo: currentUserId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();
    
    double total = 0;
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      total += (data['amount'] as num).toDouble();
    }
    
    return total;
  }

  // Calculate total expense for the time period
  Future<double> getTotalExpense(String timeFilter) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    DateTime startDate = _getStartDateFromFilter(timeFilter);
    
    QuerySnapshot snapshot = await _firestore
        .collection('expenses')
        .where('userId', isEqualTo: currentUserId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();
    
    double total = 0;
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      total += (data['amount'] as num).toDouble();
    }
    
    return total;
  }

  // Helper function to get start date based on filter
  DateTime _getStartDateFromFilter(String filter) {
    DateTime now = DateTime.now();
    switch (filter) {
      case 'Today':
        return DateTime(now.year, now.month, now.day);
      case 'Week':
        return now.subtract(Duration(days: now.weekday - 1));
      case 'Month':
        return DateTime(now.year, now.month, 1);
      case 'Year':
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(now.year, now.month, now.day);
    }
  }
}