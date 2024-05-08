import 'package:fluent_ui/fluent_ui.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tt_bindings/tt_bindings.dart';

class TPSFDisplay extends StatelessWidget {
  final Stream<(Map<int, int>, Iterable<CorrelationPair>)>? tpsfStream;
  final double integrationTimeSeconds;

  const TPSFDisplay({super.key, required this.tpsfStream, required this.integrationTimeSeconds});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: tpsfStream,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.none) {
          return const Center(
            child: Text('No measurement started'),
          );
        }
        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: ProgressRing(),
          );
        }

        final dataList = snapshot.data!.$1.entries.toList();
        final int countRate = dataList.fold<int>(0, (p, c) => p + c.value) ~/ integrationTimeSeconds;

        dataList.sort((a, b) => a.key.compareTo(b.key));
        return Column(
          children: [
            Center(child: Text('Count Rate: $countRate')),
            Expanded(
              child: SfCartesianChart(
                primaryYAxis: const LogarithmicAxis(),
                legend: const Legend(
                  isVisible: false,
                ),
                series: [
                  LineSeries<MapEntry<int, int>, int>(
                    animationDuration: 0,
                    dataSource: dataList,
                    xValueMapper: (pair, index) => pair.key,
                    yValueMapper: (pair, index) {
                      return pair.value;
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SfCartesianChart(
                primaryYAxis: const NumericAxis(
                  minimum: 0.9,
                  maximum: 1.1,
                ),
                primaryXAxis: const LogarithmicAxis(
                  minimum: 1e-6,
                  maximum: 1e-4,
                ),
                legend: const Legend(
                  isVisible: false,
                ),
                series: [
                  ScatterSeries<CorrelationPair, double>(
                    animationDuration: 0,
                    dataSource: snapshot.data!.$2.toList(),
                    xValueMapper: (pair, index) => pair.tau,
                    yValueMapper: (pair, index) {
                      return pair.correlation;
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}