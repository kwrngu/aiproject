import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../duty_roster_page.dart'; // Import DutyRosterPage

import 'leave_management_page.dart'; // Import LeaveManagementPage

class AdminDashboardPage extends StatefulWidget {
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Future<int> _getTotalPendingClaims() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('expenseClaims')
        .where('status', isEqualTo: 'Pending')
        .get();
    return querySnapshot.docs.length;
  }

  Future<int> _getTotalLeaveRequests() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('leaveApplications')
        .get();
    return querySnapshot.docs.length;
  }

  Future<int> _getTotalStaff() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('staff')
        .get();
    return querySnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
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
          childAspectRatio: 1, // Square cards
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildManagementCard(
              title: 'Leave Management',
              icon: Icons.beach_access,
              future: _getTotalLeaveRequests(),
              color: Colors.blue[100],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LeaveManagementPage()),
                );
              },
            ),
            _buildManagementCard(
              title: 'Payroll Management',
              icon: Icons.account_balance_wallet,
              future: Future.value(0), // Placeholder, replace with actual future
              color: Colors.green[100],
            ),
            _buildManagementCard(
              title: 'Attendance Management',
              icon: Icons.access_time,
              future: Future.value(0), // Placeholder, replace with actual future
              color: Colors.orange[100],
            ),
            _buildManagementCard(
              title: 'Shift Management',
              icon: Icons.schedule,
              future: Future.value(0), // Placeholder, replace with actual future
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DutyRosterPage()),
                );
              },
              color: Colors.purple[100],
            ),
            _buildManagementCard(
              title: 'Claim Management',
              icon: Icons.receipt,
              future: _getTotalPendingClaims(),
              color: Colors.red[100],
            ),
            _buildManagementCard(
              title: 'Staff Management',
              icon: Icons.people,
              future: _getTotalStaff(),
              color: Colors.yellow[100],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard({
    required String title,
    required IconData icon,
    required Future<int> future,
    Color? color,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      color: color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Theme.of(context).colorScheme.primary),
              SizedBox(height: 10),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              FutureBuilder<int>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error');
                  } else {
                    return Text('Total: ${snapshot.data}');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
