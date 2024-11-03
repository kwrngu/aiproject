import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'admin_dashboard_page/admin_dashboard_page.dart';
import 'user_dashboard_page/user_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<auth.User?> login(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      auth.UserCredential userCredential = await auth.FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      setState(() {
        _isLoading = false;
      });
      return userCredential.user;
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to login. Please check your credentials and try again.";
      });
      return null;
    }
  }

  Future<void> _redirectToDashboard(auth.User user) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('newProjectUser').doc(user.uid).get();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                auth.User? user = await login(_emailController.text, _passwordController.text);
                if (user != null) {
                  _redirectToDashboard(user);
                }
              },
              child: Text('Log In'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
              child: Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
