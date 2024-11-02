import 'package:aiproject/pages/user_dashboard_page/shift_details_card.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import '../user_profile_page.dart';
import 'leave_usage_card.dart';

import 'expense_claim_card.dart';
import 'payroll_card.dart';


class UserDashboardPage extends StatefulWidget {
  final User user;

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
            LeaveUsageCard(user: widget.user),
            ExpenseClaimCard(user: widget.user, claimStatus: "Pending"), // Example status
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
