import 'package:aiproject/models/user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/signup_page.dart';
import 'pages/login_page.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/user_dashboard_page.dart';
import 'pages/user_profile_page.dart';
import 'widget/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern App',
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.blueAccent,
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 18, fontFamily: 'Roboto'),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/signup': (context) => SignupPage(),
        '/login': (context) => LoginPage(),
        '/admin_dashboard': (context) => AdminDashboardPage(),
        '/user_dashboard': (context) => UserDashboardPage(user: User(id: '', name: '', email: '', role: '')),
        '/profile': (context) => UserProfilePage(user: User(id: '', name: '', email: '', role: '')),
      },
    );
  }
}
