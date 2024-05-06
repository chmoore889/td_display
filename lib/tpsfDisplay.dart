import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TPSFDisplay extends StatelessWidget {
  final Stream<Map<int, int>>? tpsfStream;

  const TPSFDisplay({super.key, this.tpsfStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: tpsfStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return SfCartesianChart(
          primaryYAxis: const LogarithmicAxis(),
          legend: const Legend(
            isVisible: false,
          ),
          series: [
            LineSeries<MapEntry<int, int>, int>(
              animationDuration: 0,
              dataSource: snapshot.data!.entries.toList(),
              xValueMapper: (pair, index) => pair.key,
              yValueMapper: (pair, index) {
                return pair.value;
              },
            ),
          ],
        );
      }
    );
  }
}