import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show MaterialApp, Scaffold;
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
  GatingRange gatingRange = const GatingRange(0, laserPeriod);

  Directory? measurementDirectory;
  bool enableFileOutput = false;

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
                          width: 150,
                          child: NumberBox(
                            value: integrationTimeSeconds,
                            onChanged: (val) {
                              if(val != null) {
                                integrationTimeSeconds = val;
                              }
                            },
                            smallChange: 0.1,
                            largeChange: 1,
                            min: 0.1,
                            mode: SpinButtonPlacementMode.none,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Gate Range (ps):'),
                        SizedBox(
                          width: 150,
                          child: NumberBox(
                            value: gatingRange.startPs,
                            onChanged: (val) {
                              if(val != null) {
                                gatingRange = GatingRange(val, gatingRange.endPs);
                              }
                            },
                            min: 0,
                            max: gatingRange.endPs,
                            mode: SpinButtonPlacementMode.none,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: NumberBox(
                            value: gatingRange.endPs,
                            onChanged: (val) {
                              if(val != null) {
                                gatingRange = GatingRange(gatingRange.startPs, val);
                              }
                            },
                            min: gatingRange.startPs,
                            max: laserPeriod,
                            mode: SpinButtonPlacementMode.none,
                          ),
                        ),
                      ],
                    ),
                    Button(
                      onPressed: () {
                        updateProcessingParams(
                          PostProcessingParams(
                            integrationTimeSeconds: integrationTimeSeconds,
                            gatingRange: gatingRange,
                          ),
                        );
                        setState(() {
                          integrationTimeSeconds = integrationTimeSeconds;
                          gatingRange = gatingRange;
                        });
                      },
                      child: const Text('Update Processing Params'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Stream<(Map<int, int>, Iterable<CorrelationPair>)>? newStream;
                        try {
                          newStream = startMeasurement(
                            MeasurementParams(
                              laserChannel: -1,
                              laserPeriod: laserPeriod,
                              laserTriggerVoltage: -0.5,
                              detectorChannels: [2],
                              detectorTriggerVoltage: 0.9,
                              saveDirectory: enableFileOutput ? measurementDirectory : null,
                            ),
                            PostProcessingParams(
                              integrationTimeSeconds: integrationTimeSeconds,
                              gatingRange: gatingRange,
                            ),
                          );
                        } catch(e) {
                          //Do nothing
                        }
                        setState(() {
                          stream = isRunning ? null : newStream;
                        });
                      },
                      child: Text('${isRunning ? 'Stop' : 'Start'} Measurement'),
                    ),
                    IconButton(
                      icon: const Icon(FluentIcons.fabric_folder),
                      onPressed: () {
                        final file = DirectoryPicker()
                          ..title = 'Select a directory';

                        final result = file.getDirectory();
                        if (result != null) {
                          measurementDirectory = result;
                        }
                      },
                    ),
                    Builder(
                      builder: (context) {
                        return Checkbox(
                          checked: enableFileOutput,
                          onChanged: (newState) {
                            if(newState != null) {
                              if(newState && measurementDirectory == null) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ContentDialog(
                                      title: const Text('No directory selected'),
                                      content: const Text('Please select a directory before enabling file output'),
                                      actions: [
                                        FilledButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return;
                              }
                              setState(() {
                                enableFileOutput = newState;
                              });
                            }
                          },
                        );
                      }
                    ),
                  ],
                ),
                Expanded(
                  child: TPSFDisplay(
                    tpsfStream: stream,
                    integrationTimeSeconds: integrationTimeSeconds,
                    gatingRange: gatingRange,
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
