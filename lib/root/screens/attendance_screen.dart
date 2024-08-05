import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture;
  bool isDetecting = false;
  String status = "Not Present";
  String _currentAddress = 'Loading...';
  bool isWithinWorkHours = true;

  // Firestore and FirebaseAuth instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User data
  String nik = '';
  String name = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getCurrentLocation();
    _checkWorkHours();
    _getUserData();
  }

  Future<void> _getUserData() async {
    // Get the current user
    User? user = _auth.currentUser;
    if (user != null) {
      // Retrieve user data from Firestore using the UID
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          nik = userDoc['nik'] ?? 'Unknown NIK';
          name = userDoc['name'] ?? 'Unknown Name';
        });
      }
    }
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentAddress = "Location services are disabled.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = "Location permissions are denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentAddress =
            "Location permissions are permanently denied, we cannot request permissions.";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark>? placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = "${place.subLocality}, ${place.locality}";
      });
    } else {
      setState(() {
        _currentAddress = "Location not available";
      });
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _cameraController.initialize();
    if (mounted) {
      setState(() {}); // Perbarui UI setelah inisialisasi selesai
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _scanText() async {
    try {
      if (_initializeControllerFuture != null) {
        await _initializeControllerFuture;
        final image = await _cameraController.takePicture();

        final inputImage = InputImage.fromFilePath(image.path);
        final textRecognizer = GoogleMlKit.vision.textRecognizer();
        final RecognizedText recognizedText =
            await textRecognizer.processImage(inputImage);

        // Process the recognized text
        String extractedText = recognizedText.text;
        print("Recognized text: $extractedText");

        if (extractedText.isNotEmpty) {
          setState(() {
            status = "Text Detected";
          });
        } else {
          setState(() {
            status = "No Text Detected";
          });
        }

        textRecognizer.close();
      }
    } catch (e) {
      print(e);
    }
  }

  void _checkWorkHours() {
    final now = DateTime.now();
    final startWork = DateTime(now.year, now.month, now.day, 9); // 09:00 AM
    final endWork = DateTime(now.year, now.month, now.day, 17); // 05:00 PM

    setState(() {
      isWithinWorkHours = now.isAfter(startWork) && now.isBefore(endWork);
    });
  }

  Future<void> _submitAttendance() async {
    // Collect all necessary data to store in Firestore
    final String address = _currentAddress;
    final String attendanceStatus = status;
    final DateTime timestamp = DateTime.now();

    // Check if status is "Text Detected" before submitting
    if (attendanceStatus == "Text Detected") {
      try {
        await _firestore.collection('attendances').add({
          'nik': nik,
          'name': name,
          'address': address,
          'status': attendanceStatus,
          'timestamp': timestamp,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance submitted successfully')),
        );
      } catch (e) {
        print(e);
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit attendance')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No valid text detected for submission')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[600],
      body: _initializeControllerFuture == null
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: ClipOval(
                                      child: CameraPreview(_cameraController),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: _scanText,
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: Colors.black,
                                    ),
                                    label: Text('Scan Text'),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 50, vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      textStyle: TextStyle(
                                          fontSize: 18, color: Colors.black),
                                      backgroundColor: Colors.yellow[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Details",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Divider(color: Colors.orangeAccent),
                                  SizedBox(height: 10),
                                  _buildDetailRow("NIK", nik),
                                  SizedBox(height: 20),
                                  _buildDetailRow("Name", name),
                                  SizedBox(height: 20),
                                  _buildDetailRow("Location", _currentAddress),
                                  SizedBox(height: 20),
                                  _buildDetailRow("Status", status,
                                      color: status == "Text Detected"
                                          ? Colors.green
                                          : Colors.red),
                                  if (status == "Text Detected")
                                    Column(
                                      children: [
                                        SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: isWithinWorkHours
                                              ? _submitAttendance
                                              : null,
                                          child: Text('Submit'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isWithinWorkHours
                                                ? Colors.blue
                                                : Colors.grey,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 15),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            textStyle: TextStyle(
                                                fontSize: 18,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }

  Widget _buildDetailRow(String title, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
