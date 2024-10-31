import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'user.dart';

class AdminDashboardPage extends StatefulWidget {
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Future<void> updateLeaveStatus(String leaveId, String status) async {
    await FirebaseFirestore.instance.collection('userLeaveApplication').doc(leaveId).update({
      'status': status,
    });
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
      body: Column(
        children: [
          SizedBox(height: 20),
          Text('All Leave Applications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('userLeaveApplication').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                var leaveApplications = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: leaveApplications.length,
                  itemBuilder: (context, index) {
                    var leaveApp = leaveApplications[index];
                    return ListTile(
                      title: Text("Leave from ${leaveApp['startDate'].toDate()} to ${leaveApp['endDate'].toDate()}"),
                      subtitle: Text("User: ${leaveApp['userName']} \nReason: ${leaveApp['reason']} \nType: ${leaveApp['type']} \nStatus: ${leaveApp['status']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check),
                            onPressed: () {
                              updateLeaveStatus(leaveApp.id, 'Approved');
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              updateLeaveStatus(leaveApp.id, 'Rejected');
                            },
                          ),
                        ],
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
