import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/admin_dashboard_page/admin_dashboard_page.dart';
import '../pages/user_dashboard_page/user_dashboard_page.dart';
import '../models/user.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    auth.FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        // User is signed in
        await _redirectToDashboard(user);
      } else {
        // No user is signed in
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  Future<void> _redirectToDashboard(auth.User user) async {
    DocumentSnapshot doc = await FirebaseFirestore.instanceFor(app: Firebase.app(),databaseId: 'aidatabase').collection('newProjectUser').doc(user.uid).get();
    if (doc.exists) {
      AppUser currentUser = AppUser.fromMap(doc.data() as Map<String, dynamic>);
      if (currentUser.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserDashboardPage(user: currentUser)),
        );
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
