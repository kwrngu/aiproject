import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/expense.dart';
import '../../models/expense_claim.dart';

class ClaimForm extends StatefulWidget {
  @override
  _ClaimFormState createState() => _ClaimFormState();
}

class _ClaimFormState extends State<ClaimForm> {
  List<Expense> expenses = [];
  final picker = ImagePicker();
  String? receiptUrl;

  void _addExpense(String description, double amount, DateTime date, String? receiptUrl) {
    setState(() {
      expenses.add(Expense(description: description, amount: amount, date: date, receiptUrl: receiptUrl));
    });
  }

  void _removeExpense(int index) {
    setState(() {
      expenses.removeAt(index);
    });
  }

  Future<void> _pickReceiptImage(Function(String?) onReceiptPicked) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      onReceiptPicked(pickedFile.path);
    } else {
      onReceiptPicked(null);
    }
  }

  Future<void> _showAddExpenseDialog() async {
    TextEditingController descriptionController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    DateTime date = DateTime.now();
    String? localReceiptUrl;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Expense'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount (RM)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        date = pickedDate;
                      });
                    }
                  },
                  child: Text('Select Date'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _pickReceiptImage((path) => localReceiptUrl = path),
                  child: Text('Attach Receipt (Optional)'),
                ),
                if (localReceiptUrl != null)
                  Text('Receipt attached', style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (descriptionController.text.isNotEmpty && double.tryParse(amountController.text) != null) {
                  _addExpense(descriptionController.text, double.parse(amountController.text), date, localReceiptUrl);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill out all fields')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  double _calculateTotalAmount() {
    return expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> _submitClaim() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    ExpenseClaim claim = ExpenseClaim(
      userId: userId,
      expenses: expenses,
      totalAmount: _calculateTotalAmount(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await FirebaseFirestore.instanceFor(app: Firebase.app(),databaseId: 'aidatabase').collection('expenseClaims').add(claim.toMap());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Claim submitted successfully')));
    setState(() {
      expenses.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Expense Claim', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: RM ${_calculateTotalAmount().toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _showAddExpenseDialog,
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FixedColumnWidth(40), // Numbering column
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                    3: FixedColumnWidth(50),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[300]),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Amount (RM)', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(),
                        ),
                      ],
                    ),
                    ...expenses.asMap().entries.map((entry) {
                      int index = entry.key;
                      var expense = entry.value;
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${index + 1}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(expense.description),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(expense.amount.toStringAsFixed(2)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: Icon(Icons.remove_circle),
                              onPressed: () => _removeExpense(index),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitClaim,
              child: Text('Submit Expense Claim'),
            ),
          ],
        ),
      ),
    );
  }
}
