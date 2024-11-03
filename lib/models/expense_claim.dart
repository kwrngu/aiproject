import 'package:cloud_firestore/cloud_firestore.dart';
import 'expense.dart';

class ExpenseClaim {
  String userId;
  List<Expense> expenses;
  double totalAmount;
  String status; // Pending, Approved, Rejected
  DateTime createdAt;
  DateTime updatedAt;
  String? transactionReference; // Optional transaction reference

  ExpenseClaim({
    required this.userId,
    required this.expenses,
    required this.totalAmount,
    this.status = 'Pending',
    required this.createdAt,
    required this.updatedAt,
    this.transactionReference,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'expenses': expenses.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'transactionReference': transactionReference,
    };
  }

  static ExpenseClaim fromMap(Map<String, dynamic> map) {
    return ExpenseClaim(
      userId: map['userId'],
      expenses: List<Expense>.from(map['expenses'].map((e) => Expense.fromMap(e))),
      totalAmount: map['totalAmount'],
      status: map['status'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      transactionReference: map['transactionReference'],
    );
  }
}
