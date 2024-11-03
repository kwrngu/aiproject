import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';


class ShiftDetailCard extends StatefulWidget {
  final AppUser user;

  ShiftDetailCard({required this.user});

  @override
  _ShiftDetailCardState createState() => _ShiftDetailCardState();
}

class _ShiftDetailCardState extends State<ShiftDetailCard> {
  Map<DateTime, String> userShifts = {};
  String checkInTime = "08:00 AM"; // Dummy check-in time
  String checkOutTime = "05:00 PM"; // Dummy check-out time

  @override
  void initState() {
    super.initState();
    _loadUserShifts();
  }

  void _loadUserShifts() async {
    setState(() {
      userShifts = {
        DateTime.now(): "Morning Shift"
      };
    });
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Check-in', style: TextStyle(fontSize: 16, color: Colors.white)),
                    SizedBox(height: 4),
                    Text(checkInTime, style: TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15.0),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Check-out', style: TextStyle(fontSize: 16, color: Colors.white)),
                    SizedBox(height: 4),
                    Text(checkOutTime, style: TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.schedule, size: 50, color: Theme.of(context).colorScheme.primary),
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
        ],
      ),
    );
  }
}
