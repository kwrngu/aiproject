import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String description;
  double amount;
  DateTime date;
  String? receiptUrl; // Optional receipt attachment

  Expense({
    required this.description,
    required this.amount,
    required this.date,
    this.receiptUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
      'date': date,
      'receiptUrl': receiptUrl,
    };
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      description: map['description'],
      amount: map['amount'],
      date: (map['date'] as Timestamp).toDate(),
      receiptUrl: map['receiptUrl'],
    );
  }
}
