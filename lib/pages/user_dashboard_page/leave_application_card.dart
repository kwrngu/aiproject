import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';

class LeaveApplicationsCard extends StatefulWidget {
  final AppUser user;

  LeaveApplicationsCard({required this.user});

  @override
  _LeaveApplicationsCardState createState() => _LeaveApplicationsCardState();
}

class _LeaveApplicationsCardState extends State<LeaveApplicationsCard> {
  final TextEditingController _leaveReasonController = TextEditingController();
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now().add(Duration(days: 1));
  String _selectedLeaveType = 'Annual Leave';
  int _leaveDays = 1;

  void _calculateLeaveDays() {
    setState(() {
      _leaveDays = _selectedEndDate.difference(_selectedStartDate).inDays + 1;
    });
  }

  Future<void> submitLeaveApplication(String reason, int days, String type, DateTime startDate, DateTime endDate) async {
    await FirebaseFirestore.instanceFor(app: Firebase.app(),databaseId: 'aidatabase').collection('userLeaveApplication').add({
      'userId': widget.user.id,
      'userName': widget.user.name,
      'reason': reason,
      'type': type,
      'days': days,
      'startDate': startDate,
      'endDate': endDate,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
    _leaveReasonController.clear();
    setState(() {
      _selectedStartDate = DateTime.now();
      _selectedEndDate = DateTime.now().add(Duration(days: 1));
      _selectedLeaveType = 'Annual Leave';
      _leaveDays = 1;
    });
  }

  Future<void> showLeaveApplicationDialog() async {
    _leaveReasonController.clear();
    _calculateLeaveDays();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Submit Leave Application', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: _leaveReasonController,
                      decoration: InputDecoration(
                        labelText: 'Reason for Leave',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedLeaveType,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedLeaveType = newValue!;
                        });
                      },
                      items: ['Annual Leave', 'Sick Leave', 'Unpaid Leave']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Type of Leave',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Select Leave Start Date'),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedStartDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != _selectedStartDate) {
                          setState(() {
                            _selectedStartDate = picked;
                            _calculateLeaveDays();
                          });
                        }
                      },
                      child: Text('Select Start Date'),
                    ),
                    Text("${_selectedStartDate.day}-${_selectedStartDate.month}-${_selectedStartDate.year}"),
                    SizedBox(height: 10),
                    Text('Select Leave End Date'),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedEndDate,
                          firstDate: _selectedStartDate,
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != _selectedEndDate) {
                          setState(() {
                            _selectedEndDate = picked;
                            _calculateLeaveDays();
                          });
                        }
                      },
                      child: Text('Select End Date'),
                    ),
                    Text("${_selectedEndDate.day}-${_selectedEndDate.month}-${_selectedEndDate.year}"),
                    SizedBox(height: 10),
                    Text("Total Leave Days: $_leaveDays"),
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
                  onPressed: () async {
                    await submitLeaveApplication(
                      _leaveReasonController.text,
                      _leaveDays,
                      _selectedLeaveType,
                      _selectedStartDate,
                      _selectedEndDate,
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

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
          Icon(Icons.assignment, size: 50, color: Colors.green),
          SizedBox(height: 10),
          Text('My Leave Applications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instanceFor(app: Firebase.app(),databaseId: 'aidatabase')
                  .collection('userLeaveApplication')
                  .where('userId', isEqualTo: widget.user.id)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                var leaveApplications = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: leaveApplications.length,
                  itemBuilder: (context, index) {
                    var leaveApp = leaveApplications[index];
                    return ListTile(
                      title: Text("Leave from ${leaveApp['startDate'].toDate().day}-${leaveApp['startDate'].toDate().month}-${leaveApp['startDate'].toDate().year} to ${leaveApp['endDate'].toDate().day}-${leaveApp['endDate'].toDate().month}-${leaveApp['endDate'].toDate().year}"),
                      subtitle: Text("Reason: ${leaveApp['reason']} \nType: ${leaveApp['type']} \nStatus: ${leaveApp['status']}"),
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
