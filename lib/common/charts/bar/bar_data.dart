import 'bar_chart.dart';

class BarData {
  final int weekOne;
  final int weekTwo;
  final int weekThree;
  final int weekFour;

  BarData(
      {required this.weekOne,
      required this.weekTwo,
      required this.weekThree,
      required this.weekFour});

  List<BarGraph> bardata = [];

  void initialData() {
    bardata = [
      BarGraph(x: 0, y: weekOne),
      BarGraph(x: 0, y: weekTwo),
      BarGraph(x: 0, y: weekThree),
      BarGraph(x: 0, y: weekFour),
    ];
  }
}
