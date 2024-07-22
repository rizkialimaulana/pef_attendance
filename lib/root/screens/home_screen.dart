import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentAddress = 'Loading...';
  String _currentDate = 'Loading...';
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getCurrentDate();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
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

    if (placemarks != null && placemarks.isNotEmpty) {
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

  void _getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, d MMMM y').format(now);
    setState(() {
      _currentDate = formattedDate;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.yellow[300],
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 40),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _getGreeting(),
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "User",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.all(10),
                  margin: EdgeInsets.only(right: 20),
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
                )
              ],
            ),
            SizedBox(height: 10),
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Text(_currentDate),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.black,
                    ),
                    child: Center(
                      child: Text(
                        _currentAddress,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 30),
                padding: EdgeInsets.all(10),
                color: Colors.white,
                child: Column(
                  children: [
                    Text(
                      "History Checked-in",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(show: false),
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 20,
                          // barTouchData: BarTouchData(
                          //   touchTooltipData: BarTouchTooltipData(
                          //     tooltipBgColor: Colors.blueAccent,
                          //   ),
                          //   touchCallback: (BarTouchResponse touchResponse) {
                          //     setState(() {
                          //       if (touchResponse.spot != null &&
                          //           touchResponse.touchInput is FlPanUpdate &&
                          //           touchResponse.touchInput.localPosition.dy >
                          //               0) {
                          //         touchedIndex =
                          //             touchResponse.spot!.touchedBarGroupIndex;
                          //       } else {
                          //         touchedIndex = -1;
                          //       }
                          //     });
                          //   },
                          //   handleBuiltInTouches: true,
                          // ),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  const style = TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  );
                                  Widget text;
                                  switch (value.toInt()) {
                                    case 0:
                                      text = Text('Jan', style: style);
                                      break;
                                    case 1:
                                      text = Text('Feb', style: style);
                                      break;
                                    case 2:
                                      text = Text('Mar', style: style);
                                      break;
                                    case 3:
                                      text = Text('Apr', style: style);
                                      break;
                                    case 4:
                                      text = Text('Mei', style: style);
                                      break;
                                    case 5:
                                      text = Text('Jun', style: style);
                                      break;
                                    case 6:
                                      text = Text('Jul', style: style);
                                      break;
                                    default:
                                      text = const Text('', style: style);
                                      break;
                                  }
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: text,
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [
                              BarChartRodData(
                                  toY: 3,
                                  color: Colors.yellow[800],
                                  width: 20,
                                  borderRadius: BorderRadius.circular(5),
                                  backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: 20,
                                      color: Colors.yellow[50])),
                            ]),
                            BarChartGroupData(x: 1, barRods: [
                              BarChartRodData(
                                  toY: 10,
                                  color: Colors.yellow[800],
                                  width: 20,
                                  borderRadius: BorderRadius.circular(5),
                                  backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: 20,
                                      color: Colors.yellow[50])),
                            ]),
                            BarChartGroupData(x: 2, barRods: [
                              BarChartRodData(
                                  toY: 14,
                                  color: Colors.yellow[800],
                                  width: 20,
                                  borderRadius: BorderRadius.circular(5),
                                  backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: 20,
                                      color: Colors.yellow[50])),
                            ]),
                            BarChartGroupData(x: 3, barRods: [
                              BarChartRodData(
                                  toY: 15,
                                  color: Colors.yellow[800],
                                  width: 20,
                                  borderRadius: BorderRadius.circular(5),
                                  backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: 20,
                                      color: Colors.yellow[50])),
                            ]),
                            BarChartGroupData(x: 4, barRods: [
                              BarChartRodData(
                                  toY: 13,
                                  color: Colors.yellow[800],
                                  width: 20,
                                  borderRadius: BorderRadius.circular(5),
                                  backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: 20,
                                      color: Colors.yellow[50])),
                            ]),
                            BarChartGroupData(x: 5, barRods: [
                              BarChartRodData(
                                  toY: 13,
                                  color: Colors.yellow[800],
                                  width: 20,
                                  borderRadius: BorderRadius.circular(5),
                                  backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: 20,
                                      color: Colors.yellow[50])),
                            ]),
                            BarChartGroupData(x: 6, barRods: [
                              BarChartRodData(
                                  toY: 13,
                                  color: Colors.yellow[800],
                                  width: 20,
                                  borderRadius: BorderRadius.circular(5),
                                  backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: 20,
                                      color: Colors.yellow[50])),
                            ]),
                          ],
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
    );
  }
}
