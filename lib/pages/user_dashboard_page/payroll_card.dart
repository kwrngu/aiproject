import 'package:flutter/material.dart';

class PayrollCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      margin: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet, size: 50, color: Theme.of(context).colorScheme.primary), // Changed icon
          SizedBox(height: 10),
          Text('Payroll', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Monthly Salary: \$5000', style: TextStyle(fontSize: 16)),
          Text('Overtime: \$500', style: TextStyle(fontSize: 16)),
          Text('Bonuses: \$1000', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
