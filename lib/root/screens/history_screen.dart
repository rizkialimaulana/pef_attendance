import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.yellow[300],
        child: Center(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 50),
            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "History Attendance",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 300, // Atur tinggi sesuai kebutuhan
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(show: false),
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 20,
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
                              color: Colors.yellow[50],
                            ),
                          ),
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
                              color: Colors.yellow[50],
                            ),
                          ),
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
                              color: Colors.yellow[50],
                            ),
                          ),
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
                              color: Colors.yellow[50],
                            ),
                          ),
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
                              color: Colors.yellow[50],
                            ),
                          ),
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
                              color: Colors.yellow[50],
                            ),
                          ),
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
                              color: Colors.yellow[50],
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
