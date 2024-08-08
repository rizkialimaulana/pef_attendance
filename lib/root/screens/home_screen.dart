import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentAddress = 'Loading...';
  String _currentDate = 'Loading...';
  String _checkInStatus = 'Not Checked In';
  String _checkInTime = 'N/A';
  bool _isCheckedIn = false;
  String _currentWeather = 'Sunny, 25°C';
  bool _isWithinWorkHours = true;
  String _userName = 'User';
  String _uid = '';
  Map<String, double> _attendanceOverview = {
    "Present": 20,
    "Absent": 5,
    "Late": 3,
  };
  DocumentSnapshot? _attendanceDoc;

  @override
  void initState() {
    super.initState();
    _getCurrentDate();
    _checkWorkHours();
    _getUserName();
    _getCheckInStatus();
  }

  Future<void> _getCurrentDate() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, d MMMM y').format(now);
    setState(() {
      _currentDate = formattedDate;
    });
  }

  Future<void> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['name'] ?? user.email ?? 'User';
          _uid = userDoc['nik'] ?? 'Unknown User';
        });
      }
    }
  }

  Future<void> _getCheckInStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DateTime today = DateTime.now();
      DateTime startOfToday = DateTime(today.year, today.month, today.day);

      QuerySnapshot attendanceQuery = await FirebaseFirestore.instance
          .collection('attendances')
          .where('uid', isEqualTo: _uid)
          .where('check_in', isGreaterThanOrEqualTo: startOfToday)
          .get();

      if (attendanceQuery.docs.isNotEmpty) {
        DocumentSnapshot attendanceDoc = attendanceQuery.docs.first;
        Timestamp timestamp = attendanceDoc['check_in'];
        DateTime checkInTime = timestamp.toDate();

        setState(() {
          _isCheckedIn = true;
          _checkInStatus = "Already Checked In";
          _checkInTime = DateFormat('hh:mm a').format(checkInTime);
          _attendanceDoc = attendanceDoc;
        });
      } else {
        setState(() {
          _isCheckedIn = false;
          _checkInStatus = "Not Checked In";
          _checkInTime = "N/A";
        });
      }
    }
  }

  Future<void> _checkWorkHours() async {
    final now = DateTime.now();
    final startWork = DateTime(now.year, now.month, now.day, 7); // 07:00 AM
    final endWork = DateTime(now.year, now.month, now.day, 18); // 06:00 PM

    setState(() {
      _isWithinWorkHours = now.isAfter(startWork) && now.isBefore(endWork);

      // Automatic check out if beyond work hours
      if (now.isAfter(endWork) && _isCheckedIn) {
        _isCheckedIn = false;
        _checkInStatus = "Not Checked In";
        _checkInTime = "N/A";
      }
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Night";
    }
  }

  Future<void> _navigateToAttendanceScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AttendanceScreen()),
    );

    if (result == true) {
      await _getCheckInStatus();
    }
  }

  void _showCheckInReminder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reminder'),
          content: Text('Don\'t forget to check in!'),
          actions: <Widget>[
            TextButton(
              child: Text('Check In Now'),
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToAttendanceScreen();
              },
            ),
            TextButton(
              child: Text('Later'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _refresh() async {
    await _getCurrentDate();
    await _checkWorkHours();
    await _getCheckInStatus();
    await _getUserName();
  }

  Future<void> _checkOut() async {
    if (_attendanceDoc != null) {
      try {
        await _attendanceDoc!.reference.update({
          'check_out': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checked out successfully')),
        );
        setState(() {
          _isCheckedIn = false;
          _checkInStatus = "Not Checked In";
          _checkInTime = "N/A";
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to check out')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkWorkHours(); // Check work hours each time build is called

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
              color: Colors.yellow[600],
              child: Column(
                children: <Widget>[
                  SizedBox(height: 40),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _getGreeting(),
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                            SizedBox(height: 5),
                            Text(
                              _userName,
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Spacer(),
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(
                              'https://www.example.com/profile_picture.jpg'),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.all(10),
                          margin: EdgeInsets.only(left: 20),
                          child: GestureDetector(
                            onTap: _showCheckInReminder,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  Icons.notifications_outlined,
                                  size: 25.0,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          child: Text(
                            _currentDate,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        Flexible(
                          flex: 3,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.black,
                            ),
                            child: Center(
                              child: Text(
                                _currentAddress,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          "Today's Check-In Status",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 20),
                        Text(
                          _checkInStatus,
                          style: TextStyle(
                            fontSize: 18,
                            color: _isCheckedIn ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _checkInTime,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Current Weather",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _currentWeather,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          "Attendance Overview",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: _attendanceOverview.keys.map((key) {
                            return Column(
                              children: [
                                Text(
                                  key,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  _attendanceOverview[key].toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isCheckedIn ? Colors.red : Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isWithinWorkHours
                          ? (_isCheckedIn
                              ? _checkOut
                              : _navigateToAttendanceScreen)
                          : null,
                      child: Text(
                        _isCheckedIn ? "Check Out" : "Check In",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to Leave Request
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Leave Request",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to Attendance History
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Attendance History",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
