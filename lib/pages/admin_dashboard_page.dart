import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../models/user.dart';
import 'duty_roster_page.dart'; // Import DutyRosterPage


class AdminDashboardPage extends StatefulWidget {
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
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
      body: Column(
        children: [
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DutyRosterPage()),
              );
            },
            child: Text('Manage Duty Roster'),
          ),
          SizedBox(height: 20),
          const Text('View Expense Claims'),
          SizedBox(height: 20),
          Text(
              'All User Leave Applications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('userLeaveApplication')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                var leaveApplications = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: leaveApplications.length,
                  itemBuilder: (context, index) {
                    var leaveApp = leaveApplications[index];
                    return Card(
                      margin:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      child: ListTile(
                        title: Text(
                            "Leave from ${leaveApp['startDate'].toDate().day}-${leaveApp['startDate'].toDate().month}-${leaveApp['startDate'].toDate().year} to ${leaveApp['endDate'].toDate().day}-${leaveApp['endDate'].toDate().month}-${leaveApp['endDate'].toDate().year}"),
                        subtitle: Text(
                            "User: ${leaveApp['userName']} \nReason: ${leaveApp['reason']} \nType: ${leaveApp['type']} \nStatus: ${leaveApp['status']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('userLeaveApplication')
                                    .doc(leaveApp.id)
                                    .update({'status': 'Approved'});
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('userLeaveApplication')
                                    .doc(leaveApp.id)
                                    .update({'status': 'Rejected'});
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}