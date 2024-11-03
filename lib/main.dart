import 'package:aiproject/models/user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/signup_page.dart';
import 'pages/login_page.dart';
import 'pages/admin_dashboard_page/admin_dashboard_page.dart';
import 'pages/user_dashboard_page/user_dashboard_page.dart';
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
    return MaterialApp(debugShowCheckedModeBanner: false,
      title: 'Modern App',
      theme: ThemeData(
        useMaterial3: true,  // Use Material 3
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // Material 3 color scheme
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 18, fontFamily: 'Roboto'),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(

            textStyle: TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/signup': (context) => SignupPage(),
        '/login': (context) => LoginPage(),
        '/admin_dashboard': (context) => AdminDashboardPage(),
        '/user_dashboard': (context) => UserDashboardPage(user: AppUser(id: '', name: '', email: '', role: '')),
        '/profile': (context) => UserProfilePage(user: AppUser(id: '', name: '', email: '', role: '')),
      },
    );
  }
}
