import 'package:flutter/material.dart';
import 'package:pef_attendance_system/auth/screens/login_screen.dart';
import 'package:pef_attendance_system/main_screen.dart';
import 'package:pef_attendance_system/root/screens/history_screen.dart';
import 'package:pef_attendance_system/root/screens/home_screen.dart';
import 'package:pef_attendance_system/root/screens/inbox_screen.dart';
import 'package:pef_attendance_system/root/screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Premiere Equity Futures Attendance System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/main',
      routes: {
        '/main': (context) => MainScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/history': (context) => HistoryScreen(),
        '/profile': (context) => ProfileScreen(),
        '/inbox': (context) => InboxScreen(),
      },
    );
  }
}
