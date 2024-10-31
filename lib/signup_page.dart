import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> signUp(String name, String email, String password) async {
    try {
      auth.UserCredential userCredential = await auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User newUser = User(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        role: 'user', // default role
      );

      await FirebaseFirestore.instance
          .collection('newProjectUser')
          .doc(newUser.id)
          .set(newUser.toMap());
      // ignore: avoid_print
      print("User Registered");
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on auth.FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print("Failed to register: $e");
      // Handle signup error, e.g., show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Signup failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person), // Add prefix icon
                border: OutlineInputBorder(), // Add outline border
              ),
            ),
            const SizedBox(height: 16), // Add spacing
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
            FilledButton(
              // Use FilledButton for Material 3
              onPressed: () async {
                await signUp(_nameController.text, _emailController.text,
                    _passwordController.text);
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 50), // Set button size
              ),
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 16), // Add spacing
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Already have an account? Log In'),
            ),
          ],
        ),
      ),
    );
  }
}