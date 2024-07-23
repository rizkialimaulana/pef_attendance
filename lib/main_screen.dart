import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:pef_attendance_system/root/screens/home_screen.dart';
import 'package:pef_attendance_system/root/screens/inbox_screen.dart';
import 'package:pef_attendance_system/root/screens/attendance_screen.dart';
import 'package:pef_attendance_system/root/screens/history_screen.dart';
import 'package:pef_attendance_system/root/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    InboxScreen(),
    AttendanceScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color.fromARGB(255, 253, 216, 53),
        items: const <Widget>[
          Icon(Icons.home_outlined, size: 30),
          Icon(Icons.calendar_month_outlined, size: 30),
          Icon(Icons.add_outlined, size: 30),
          Icon(Icons.history, size: 30),
          Icon(Icons.person_2_outlined, size: 30),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );
  }
}
