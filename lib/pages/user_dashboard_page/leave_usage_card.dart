import 'package:flutter/material.dart';
import '../../models/user.dart';


class LeaveUsageCard extends StatefulWidget {
  final AppUser user;

  LeaveUsageCard({required this.user});

  @override
  _LeaveUsageCardState createState() => _LeaveUsageCardState();
}

class _LeaveUsageCardState extends State<LeaveUsageCard> {
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
          Icon(Icons.calendar_today, size: 50, color: Theme.of(context).colorScheme.primary),
          SizedBox(height: 10),
          Text('My Leave', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Annual Leave: 12 days', style: TextStyle(fontSize: 16)),
          Text('Sick Leave: 5 days', style: TextStyle(fontSize: 16)),
          Text('Unpaid Leave: 2 days', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
