import 'package:flutter/material.dart';
import 'package:td_display/tpsfDisplay.dart';
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
  Stream<Map<int, int>>? stream;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    stream = startMeasurement(const MeasurementParams(
                      laserChannel: -1,
                      laserPeriod: 12500,
                      laserTriggerVoltage: -0.5,
                      detectorChannels: [2],
                      detectorTriggerVoltage: 0.9,
                    ));
                  });
                },
                child: const Text('Start Measurement'),
              ),
              Expanded(
                child: TPSFDisplay(
                  tpsfStream: stream,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
