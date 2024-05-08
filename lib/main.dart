import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:td_display/plot_display.dart';
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

  static const int laserPeriod = 12500;

  double integrationTimeSeconds = 1.0;
  GatingRange gatingRange = const GatingRange(8000, 9000);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FluentApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        const Text('Integration Time (s):'),
                        SizedBox(
                          width: 100,
                          child: NumberBox(
                            value: integrationTimeSeconds,
                            onChanged: (val) {
                              setState(() {
                                if(val != null) {
                                  integrationTimeSeconds = val;
                                }
                              });
                            },
                            smallChange: 0.1,
                            largeChange: 1,
                            min: 0.1,
                            mode: SpinButtonPlacementMode.none,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          stream = isRunning ? null : 
                            startMeasurement(
                              const MeasurementParams(
                                laserChannel: -1,
                                laserPeriod: laserPeriod,
                                laserTriggerVoltage: -0.5,
                                detectorChannels: [2],
                                detectorTriggerVoltage: 0.9,
                              ),
                              PostProcessingParams(
                                integrationTimeSeconds: integrationTimeSeconds,
                                gatingRange: gatingRange,
                              ),
                            );
                        });
                      },
                      child: Text('${isRunning ? 'Stop' : 'Start'} Measurement'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        updateProcessingParams(
                          PostProcessingParams(
                            integrationTimeSeconds: integrationTimeSeconds,
                            gatingRange: gatingRange,
                          ),
                        );
                      },
                      child: const Text('Update Processing Params'),
                    ),
                  ],
                ),
                Expanded(
                  child: TPSFDisplay(
                    tpsfStream: stream,
                    integrationTimeSeconds: integrationTimeSeconds,
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
