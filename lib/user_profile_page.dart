import 'package:flutter/material.dart';
import 'user.dart';

class UserProfilePage extends StatelessWidget {
  final User user;

  UserProfilePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile: ${user.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user.profilePictureUrl ?? 'https://example.com/default-profile-picture.jpg'),
            ),
            SizedBox(height: 16),
            Text('Name: ${user.name}', style: TextStyle(fontSize: 18)),
            Text('Email: ${user.email}', style: TextStyle(fontSize: 18)),
            Text('Role: ${user.role}', style: TextStyle(fontSize: 18)),
            Divider(),
            Text('Leave Usage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // Example leave usage details
            Text('Total Leaves: 20'),
            Text('Used Leaves: 10'),
            Text('Remaining Leaves: 10'),
            Divider(),
            Text('Leave Applications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // Example leave application details
            ListTile(
              title: Text('Leave Application 1'),
              subtitle: Text('Status: Pending'),
            ),
            Divider(),
            Text('Attendance Record', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // Example attendance details
            Text('Attendance: 90%'),
            Divider(),
            Text('Duty Roster Shift Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // Example duty roster details
            Text('Shift: Morning'),
          ],
        ),
      ),
    );
  }
}
