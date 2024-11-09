import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveManagementPage extends StatefulWidget {
  @override
  _LeaveManagementPageState createState() => _LeaveManagementPageState();
}

class _LeaveManagementPageState extends State<LeaveManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Management', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 4.0,
          tabs: [
            Tab(
              text: 'Pending',
              icon: Icon(Icons.pending),
            ),
            Tab(
              text: 'Approved & Rejected',
              icon: Icon(Icons.done_all),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaveList('Pending'),
          _buildLeaveList('ApprovedAndRejected'),
        ],
      ),
    );
  }

  Widget _buildLeaveList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instanceFor(app: Firebase.app(),databaseId: 'aidatabase').collection('leaveApplications').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        var leaveApplications = snapshot.data!.docs.where((doc) {
          if (status == 'Pending') {
            return doc['status'] == 'Pending';
          } else {
            return doc['status'] == 'Approved' || doc['status'] == 'Rejected';
          }
        }).toList();
        return ListView.builder(
          itemCount: leaveApplications.length,
          itemBuilder: (context, index) {
            var leaveApp = leaveApplications[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: ListTile(
                title: Text(
                    "Leave from ${leaveApp['startDate'].toDate().day}-${leaveApp['startDate'].toDate().month}-${leaveApp['startDate'].toDate().year} to ${leaveApp['endDate'].toDate().day}-${leaveApp['endDate'].toDate().month}-${leaveApp['endDate'].toDate().year}"),
                subtitle: Text(
                    "User: ${leaveApp['userName']} \nReason: ${leaveApp['reason']}  \nStatus: ${leaveApp['status']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status == 'Pending')
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          FirebaseFirestore.instanceFor(app: Firebase.app(),databaseId: 'aidatabase')
                              .collection('leaveApplications')
                              .doc(leaveApp.id)
                              .update({'status': 'Approved'});
                        },
                      ),
                    if (status == 'Pending')
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          FirebaseFirestore.instanceFor(app: Firebase.app(),databaseId: 'aidatabase')
                              .collection('leaveApplications')
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
    );
  }
}
