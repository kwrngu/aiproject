import 'package:aiproject/pages/user_dashboard_page/user_leave_details_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../../models/user.dart';
import '../user_profile_page.dart';
import 'shift_details_card.dart';

import 'payroll_card.dart';
import '../expense_claim_details_page/expense_claim_details_page.dart';


class UserDashboardPage extends StatefulWidget {
  final AppUser user;

  UserDashboardPage({required this.user});

  @override
  _UserDashboardPageState createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  bool isCheckedIn = false;

  void _checkIn() {
    setState(() {
      isCheckedIn = true;
    });
    // Add your check-in logic here
  }

  void _checkOut() {
    setState(() {
      isCheckedIn = false;
    });
    // Add your check-out logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () {
              // Handle notification click
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfilePage(user: widget.user)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () async {
              await auth.FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            ShiftDetailCard(user: widget.user),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserLeaveDetailsPage(user: widget.user)),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                margin: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.beach_access, size: 50, color: Theme.of(context).colorScheme.primary),
                    SizedBox(height: 10),
                    Text('My Leave', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExpenseClaimDetailsPage(user: widget.user)),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                margin: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt, size: 50, color: Theme.of(context).colorScheme.primary),
                    SizedBox(height: 10),
                    Text('Expense Claim', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            PayrollCard(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isCheckedIn ? _checkOut : _checkIn,
        icon: Icon(isCheckedIn ? Icons.logout : Icons.login),
        label: Text(isCheckedIn ? 'Check Out' : 'Check In'),
      ),
    );
  }
}
