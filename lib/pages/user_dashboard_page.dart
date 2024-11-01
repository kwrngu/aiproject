import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/user.dart';
import '../widget/leave_application_card.dart';
import '../widget/shift_details_card.dart';
import 'user_profile_page.dart';

class UserDashboardPage extends StatefulWidget {
  final User user;

  UserDashboardPage({required this.user});

  @override
  _UserDashboardPageState createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
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
            ShiftDetailCard(user: widget.user),
            LeaveApplicationsCard(user: widget.user),

          ],
        ),
      ),
    );
  }
}
