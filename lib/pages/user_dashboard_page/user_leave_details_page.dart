import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user.dart';

class UserLeaveDetailsPage extends StatefulWidget {
  final AppUser user;

  UserLeaveDetailsPage({required this.user});

  @override
  _UserLeaveDetailsPageState createState() => _UserLeaveDetailsPageState();
}

class _UserLeaveDetailsPageState extends State<UserLeaveDetailsPage> with SingleTickerProviderStateMixin {
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

  Future<void> _createLeaveApplication(String reason, DateTime startDate, DateTime endDate) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('leaveApplications').add({
        'userId': user.uid,
        'userName': widget.user.name,
        'reason': reason,
        'startDate': startDate,
        'endDate': endDate,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Leave application submitted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Leave Details', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 4.0,
          tabs: [
            Tab(text: 'Pending', icon: Icon(Icons.pending)),
            Tab(text: 'Previous', icon: Icon(Icons.history)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showLeaveApplicationDialog();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaveList('Pending'),
          _buildLeaveList('Previous'),
        ],
      ),
    );
  }

  Widget _buildLeaveList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('leaveApplications')
          .where('userId', isEqualTo: widget.user.id)
          .snapshots(),
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
                subtitle: Text("Reason: ${leaveApp['reason']} \nStatus: ${leaveApp['status']}"),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showLeaveApplicationDialog() async {
    TextEditingController reasonController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Leave Application'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedStartDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedStartDate != null) {
                      setState(() {
                        startDate = pickedStartDate;
                      });
                    }
                  },
                  child: Text('Select Start Date'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedEndDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedEndDate != null) {
                      setState(() {
                        endDate = pickedEndDate;
                      });
                    }
                  },
                  child: Text('Select End Date'),
                ),
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
              child: Text('Submit'),
              onPressed: () {
                if (reasonController.text.isNotEmpty) {
                  _createLeaveApplication(reasonController.text, startDate, endDate);
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
}
