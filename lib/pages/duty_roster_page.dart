import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user.dart';

class DutyRosterPage extends StatefulWidget {
  @override
  _DutyRosterPageState createState() => _DutyRosterPageState();
}

class _DutyRosterPageState extends State<DutyRosterPage> {
  Map<String, Map<DateTime, String>> dutyRoster = {};
  DateTime selectedMonth = DateTime.now();
  Map<String, String> userNames = {}; // Store user names

  ScrollController _horizontalScrollController = ScrollController();
  ScrollController _verticalScrollController = ScrollController();

  Future<void> loadDutyRoster() async {
    var usersSnapshot = await FirebaseFirestore.instance.collection('newProjectUser').get();
    for (var userDoc in usersSnapshot.docs) {
      var userId = userDoc.id;
      var userName = userDoc['name'];
      userNames[userId] = userName;
      var shiftsSnapshot = await FirebaseFirestore.instance
          .collection('dutyRosters')
          .doc(userId)
          .collection('shifts')
          .where('date', isGreaterThanOrEqualTo: DateTime(selectedMonth.year, selectedMonth.month, 1))
          .where('date', isLessThan: DateTime(selectedMonth.year, selectedMonth.month + 1, 1))
          .get();

      setState(() {
        dutyRoster[userId] = {};
        for (var shiftDoc in shiftsSnapshot.docs) {
          var date = (shiftDoc['date'] as Timestamp).toDate();
          dutyRoster[userId]![date] = shiftDoc['shift'];
        }
      });
    }
  }

  Future<void> saveDutyRoster() async {
    for (var userId in dutyRoster.keys) {
      for (var date in dutyRoster[userId]!.keys) {
        var shift = dutyRoster[userId]![date];
        await FirebaseFirestore.instance.collection('dutyRosters').doc(userId).collection('shifts').doc(date.toIso8601String()).set({
          'userId': userId,
          'date': date,
          'shift': shift,
        });
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Duty roster saved successfully')));
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    loadDutyRoster();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Duty Roster'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveDutyRoster,
          ),
        ],
      ),
      body: Scrollbar(
        controller: _horizontalScrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: Scrollbar(
            controller: _verticalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _verticalScrollController,
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('User')),
                  for (var i = 1; i <= 31; i++) DataColumn(label: Text(i.toString())),
                ],
                rows: dutyRoster.keys.map((userId) {
                  return DataRow(
                    cells: [
                      DataCell(Text(userNames[userId] ?? 'Unknown')), // Display user name
                      for (var i = 1; i <= 31; i++) DataCell(
                        DropdownButton<String>(
                          value: dutyRoster[userId]?[DateTime(selectedMonth.year, selectedMonth.month, i)] ?? 'None',
                          onChanged: (newValue) {
                            setState(() {
                              dutyRoster[userId]![DateTime(selectedMonth.year, selectedMonth.month, i)] = newValue!;
                            });
                          },
                          items: ['None', 'Shift 1', 'Shift 2', 'Shift 3'].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
