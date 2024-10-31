import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user.dart';
import 'admin_dashboard_page.dart';
import 'user_dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

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
      auth.UserCredential userCredential = await auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      setState(() {
        _isLoading = false;
      });
      return userCredential.user;
    } on auth.FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message; // Use Firebase error message
      });
      return null;
    }
  }

  Future<void> _redirectToDashboard(auth.User user) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('newProjectUser')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      User currentUser = User.fromMap(doc.data() as Map<String, dynamic>);
      if (currentUser.role == 'admin') {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardPage()),
        );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserDashboardPage(user: currentUser)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email), // Add prefix icon
                border: OutlineInputBorder(), // Add outline border
              ),
            ),
            const SizedBox(height: 16), // Add spacing
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock), // Add prefix icon
                border: OutlineInputBorder(), // Add outline border
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24), // Add spacing
            _isLoading
                ? const CircularProgressIndicator()
                : FilledButton( // Use FilledButton for Material 3
              onPressed: () async {
                auth.User? user = await login(
                    _emailController.text, _passwordController.text);
                if (user != null) {
                  _redirectToDashboard(user);
                }
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 50), // Set button size
              ),
              child: const Text('Log In'),
            ),
            const SizedBox(height: 16), // Add spacing
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
              child: const Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}