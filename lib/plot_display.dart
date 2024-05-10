import 'package:fluent_ui/fluent_ui.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tt_bindings/tt_bindings.dart';

class TPSFDisplay extends StatefulWidget {
  final Stream<(Map<int, int>, Iterable<CorrelationPair>)>? tpsfStream;
  final PostProcessingParams params;

  const TPSFDisplay({
    super.key,
    required this.tpsfStream,
    required this.params,
  });

  @override
  State<TPSFDisplay> createState() => _TPSFDisplayState();
}

class _TPSFDisplayState extends State<TPSFDisplay> {
  double yMin = 0.95, yMax = 1.25;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.tpsfStream,
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
        final int countRate = dataList.fold<int>(0, (p, c) => p + c.value) ~/ (widget.params.integrationTimePs / 1e12);

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
                  AreaSeries<MapEntry<int, int>, int>(
                    animationDuration: 0,
                    dataSource: dataList.where((element) => widget.params.gatingRange.inRange(element.key)).toList(),
                    xValueMapper: (pair, index) => pair.key,
                    yValueMapper: (pair, index) {
                      return pair.value;
                    },
                  ),
                ],
              ),
            ),
            Row(
              children: [
                const Text('Y Scale: '),
                SizedBox(
                  width: 100,
                  child: NumberBox(
                    value: yMin,
                    onChanged: (e) {
                      setState(() {
                        yMin = e ?? yMin;
                      });
                    },
                    mode: SpinButtonPlacementMode.none,
                    clearButton: false,
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: NumberBox(
                    value: yMax,
                    onChanged: (e) {
                      setState(() {
                        yMax = e ?? yMax;
                      });
                    },
                    mode: SpinButtonPlacementMode.none,
                    clearButton: false,
                  ),
                ),
              ],
            ),
            Expanded(
              child: SfCartesianChart(
                primaryYAxis: NumericAxis(
                  minimum: yMin,
                  maximum: yMax,
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