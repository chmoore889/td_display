import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:td_display/measurement_input.dart';
import 'package:td_display/plot_display.dart';
import 'package:td_display/processing_input.dart';
import 'package:tt_bindings/tt_bindings.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Stream<(Map<int, int>, Iterable<CorrelationPair>)>? stream;

  get isRunning => stream != null;

  LaserFrequency laserFrequency = LaserFrequency.eighty;

  late PostProcessingParams processingParams = PostProcessingParams(
    integrationTimeSeconds: 1.0,
    gatingRange: GatingRange(0, laserFrequency.periodInPs),
    activeChannel: 2,
  );

  Directory? measurementDirectory;
  bool enableFileOutput = false;

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      home: Acrylic(
        child: ScaffoldPage.withPadding(
          header: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ProcessingInput(
                  laserPeriod: laserFrequency.periodInPs,
                  initialParams: processingParams,
                  processingParamsCallback: (params) {
                    setState(() {
                      processingParams = params;
                    });
                    updateProcessingParams(processingParams);
                  },
                ),
              ),
              MeasurementInput(
                processingParams: processingParams,
                isRunning: isRunning,
                streamCallback: (newStream) {
                  setState(() {
                    stream = newStream;
                  });
                },
                initialLaserFrequency: laserFrequency,
                laserFrequencyCallback: (newFreq) {
                  setState(() {
                    laserFrequency = newFreq;
                  });
                },
              ),
            ],
          ),
          content: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: TPSFDisplay(
                    tpsfStream: stream,
                    params: processingParams,
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
