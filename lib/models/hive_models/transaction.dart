import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String userId;
  
  @HiveField(2)
  String type;
  
  @HiveField(3)
  String category;
  
  @HiveField(4)
  double amount;
  
  @HiveField(5)
  String description;
  
  @HiveField(6)
  String wallet;
  
  @HiveField(7)
  DateTime date;
  
  @HiveField(8)
  bool isSynced;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    required this.wallet,
    required this.date,
    this.isSynced = true,
  });

  // Convert from Firebase document
  factory TransactionModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return TransactionModel(
      id: docId,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      description: data['description'] ?? '',
      wallet: data['wallet'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      isSynced: true,
    );
  }

  // Convert to Firebase document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'category': category,
      'amount': amount,
      'description': description,
      'wallet': wallet,
      'date': Timestamp.fromDate(date),
    };
  }

  // Convert to Map for display
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'category': category,
      'amount': amount,
      'description': description,
      'wallet': wallet,
      'date': Timestamp.fromDate(date),
      'isSynced': isSynced,
    };
  }
}