import 'package:fluent_ui/fluent_ui.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tt_bindings/tt_bindings.dart';

class TPSFDisplay extends StatelessWidget {
  final Stream<(Map<int, int>, Iterable<CorrelationPair>)>? tpsfStream;

  const TPSFDisplay({super.key, this.tpsfStream});

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
        dataList.sort((a, b) => a.key.compareTo(b.key));
        return SfCartesianChart(
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
        );
      }
    );
  }
}