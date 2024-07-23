import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
        // backgroundColor: Colors.yellow[50],
      ),
      body: _initializeControllerFuture == null
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
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
                                  icon: Icon(Icons.camera_alt),
                                  label: Text('Scan Face'),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 15),
                                    // primary: Colors.orangeAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    textStyle: TextStyle(fontSize: 18),
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
                          elevation: 5,
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
                                _buildDetailRow("Status", status,
                                    color: status == "Present"
                                        ? Colors.green
                                        : Colors.red),
                              ],
                            ),
                          ),
                        ),
                      ],
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
