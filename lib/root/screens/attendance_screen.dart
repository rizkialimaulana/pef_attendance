import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getCurrentLocation();
    _checkWorkHours();
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

    if (placemarks != true && placemarks.isNotEmpty) {
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

  Future<void> _scanFace() async {
    try {
      if (_initializeControllerFuture != null) {
        await _initializeControllerFuture;
        final image = await _cameraController.takePicture();

        final inputImage = InputImage.fromFilePath(image.path);
        final faceDetector = GoogleMlKit.vision.faceDetector();
        final List<Face> faces = await faceDetector.processImage(inputImage);

        if (faces.isNotEmpty) {
          setState(() {
            status = "Present";
          });
        } else {
          setState(() {
            status = "Not Present";
          });
        }

        faceDetector.close();
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

  void _submitAttendance() {
    Navigator.of(context).pop(true);
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
                                    onPressed: _scanFace,
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: Colors.black,
                                    ),
                                    label: Text('Scan Face'),
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
                                  _buildDetailRow("NIK", "1234567890"),
                                  SizedBox(height: 20),
                                  _buildDetailRow("Name", "John Doe"),
                                  SizedBox(height: 20),
                                  _buildDetailRow("Location", _currentAddress),
                                  SizedBox(height: 20),
                                  _buildDetailRow("Status", status,
                                      color: status == "Present"
                                          ? Colors.green
                                          : Colors.red),
                                  if (status == "Present")
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
