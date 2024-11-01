import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';
import 'user_profile_page.dart';

class UserDashboardPage extends StatefulWidget {
  final User user;

  UserDashboardPage({required this.user});

  @override
  _UserDashboardPageState createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  final TextEditingController _leaveReasonController = TextEditingController();
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now().add(Duration(days: 1));
  String _selectedLeaveType = 'Annual Leave';
  int _leaveDays = 1;
  Map<DateTime, String> userShifts = {};

  @override
  void initState() {
    super.initState();
    _loadUserShifts();
  }

  void _loadUserShifts() async {
    var shiftsSnapshot = await FirebaseFirestore.instance
        .collection('dutyRosters')
        .doc(widget.user.id)
        .collection('shifts')
        .get();

    setState(() {
      for (var shiftDoc in shiftsSnapshot.docs) {
        var date = (shiftDoc['date'] as Timestamp).toDate();
        userShifts[date] = shiftDoc['shift'];
        print(userShifts);
      }
    });
  }

  void _calculateLeaveDays() {
    setState(() {
      _leaveDays = _selectedEndDate.difference(_selectedStartDate).inDays + 1;
    });
  }
  Future<void> submitLeaveApplication(String reason, int days, String type, DateTime startDate, DateTime endDate) async {
    await FirebaseFirestore.instance.collection('userLeaveApplication').add({
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
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notification click
            },
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfilePage(user: widget.user)),
              );
            },
          ),
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
          children: [
            _buildShiftDetailCard(),
            _buildLeaveApplicationsCard(),
            _buildSubmitLeaveApplicationCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftDetailCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      margin: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 50, color: Colors.blue),
          SizedBox(height: 10),
          Text('Today\'s Shift', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          if (userShifts[DateTime.now()] != null)
            Text(
              'Shift: ${userShifts[DateTime.now()]}',
              style: TextStyle(fontSize: 16),
            )
          else
            Text(
              'No shift assigned for today',
              style: TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildLeaveApplicationsCard() {
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
              stream: FirebaseFirestore.instance
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

  Widget _buildSubmitLeaveApplicationCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      margin: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.send, size: 50, color: Colors.orange),
          SizedBox(height: 10),
          Text('Submit Leave Application', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ElevatedButton(
            onPressed: showLeaveApplicationDialog,
            child: Text('Submit Leave Application'),
          ),
        ],
      ),
    );
  }
}

