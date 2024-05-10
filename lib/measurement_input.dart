import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:tt_bindings/tt_bindings.dart';

class MeasurementInput extends StatefulWidget {
  final PostProcessingParams processingParams;
  final ValueChanged<Stream<(Map<int, int>, Iterable<CorrelationPair>)>?>? streamCallback;
  final LaserFrequency initialLaserFrequency;
  final ValueChanged<LaserFrequency>? laserFrequencyCallback;
  final bool isRunning;

  const MeasurementInput({
    super.key,
    required this.processingParams,
    required this.isRunning,
    required this.initialLaserFrequency,
    this.streamCallback,
    this.laserFrequencyCallback,
  });

  @override
  State<MeasurementInput> createState() => _MeasurementInputState();
}

class _MeasurementInputState extends State<MeasurementInput> {
  bool enableFileOutput = false;
  Directory? measurementDirectory;
  late LaserFrequency laserFrequency = widget.initialLaserFrequency;

  int laserChannel = 1;
  EdgeType laserEdge = EdgeType.falling;
  List<int> detectorChannels = [2];
  EdgeType detectorEdge = EdgeType.rising;
  double laserChannelVoltage = -0.5;
  double detectorChannelVoltage = 0.9;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ComboBox<LaserFrequency>(
                value: laserFrequency,
                items: LaserFrequency.values.map((e) {
                  return ComboBoxItem(
                    value: e,
                    child: Text(e.toString()),
                  );
                }).toList(),
                onChanged: (val) => widget.laserFrequencyCallback?.call(laserFrequency = val ?? laserFrequency),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
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
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text('Save output?'),
                  const SizedBox(width: 5),
                  Checkbox(
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
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Button(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ContentDialog(
                        title: const Text('Set channels'),
                        content: StatefulBuilder(
                          builder: (context, setState) {
                            return Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Laser:'),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Edge and Voltage'),
                                            Row(
                                              children: [
                                                EdgeSelector(
                                                  defaultEdge: laserEdge,
                                                  onChanged: (edge) {
                                                    laserEdge = edge;
                                                  },
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 200,
                                              child: NumberBox(
                                                value: laserChannelVoltage,
                                                onChanged: (newVal) {
                                                  if(newVal != null) {
                                                    laserChannelVoltage = newVal;
                                                  }
                                                },
                                                smallChange: 0.1,
                                                largeChange: 1,
                                                mode: SpinButtonPlacementMode.inline,
                                                clearButton: false,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Text('Channel Select'),
                                      SizedBox(
                                        width: 100,
                                        child: NumberBox(
                                          min: 1,
                                          max: 8,
                                          value: laserChannel,
                                          onChanged: (newVal) {
                                            if(newVal == null) {
                                              return;
                                            }
                                            setState(() {
                                              laserChannel = newVal;
                                              if(detectorChannels.contains(newVal)) {
                                                detectorChannels.remove(newVal);
                                              }
                                            });
                                          },
                                          clearButton: false,
                                          mode: SpinButtonPlacementMode.inline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Detectors:'),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Edge and Voltage'),
                                            Row(
                                              children: [
                                                EdgeSelector(
                                                  defaultEdge: detectorEdge,
                                                  onChanged: (edge) {
                                                    detectorEdge = edge;
                                                  },
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 200,
                                              child: NumberBox(
                                                value: detectorChannelVoltage,
                                                onChanged: (newVal) {
                                                  if(newVal != null) {
                                                    detectorChannelVoltage = newVal;
                                                  }
                                                },
                                                smallChange: 0.1,
                                                largeChange: 1,
                                                mode: SpinButtonPlacementMode.inline,
                                                clearButton: false,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Text('Channel Select'),
                                      Wrap(
                                        children: [
                                          for (var i = 1; i <= 8; i++)
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Text('$i'),
                                                  Checkbox(
                                                    checked: detectorChannels.contains(i),
                                                    onChanged: laserChannel == i ? null : (newVal) {
                                                      if(newVal != null) {
                                                        setState(() {
                                                          if(newVal) {
                                                            detectorChannels.add(i);
                                                          }
                                                          else {
                                                            detectorChannels.remove(i);
                                                          }
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                        ),
                        actions: [
                          FilledButton(
                            onPressed: () async {
                              if(detectorChannels.isEmpty) {
                                displayInfoBar(context, builder: (context, close) {
                                  return InfoBar(
                                    title: const Text('No detector channels'),
                                    content: const Text(
                                        'Detector channels must be selected'),
                                    action: IconButton(
                                      icon: const Icon(FluentIcons.clear),
                                      onPressed: close,
                                    ),
                                    severity: InfoBarSeverity.error,
                                  );
                                });
                              }
                              else {
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Set channels'),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FilledButton(
            onPressed: () {
              if(widget.isRunning) {
                widget.streamCallback?.call(null);
              }
              else {
                Stream<(Map<int, int>, Iterable<CorrelationPair>)>? newStream;
                try {
                  newStream = startMeasurement(
                    MeasurementParams(
                      laserChannel: laserEdge.setChannel(laserChannel),
                      laserPeriod: laserFrequency.periodInPs,
                      laserTriggerVoltage: laserChannelVoltage,
                      detectorChannels: detectorChannels.map((e) => detectorEdge.setChannel(e)).toList(),
                      detectorTriggerVoltage: detectorChannelVoltage,
                      saveDirectory: enableFileOutput ? measurementDirectory : null,
                    ),
                    widget.processingParams,
                  );
                } catch(e) {
                  //Do nothing
                }
                widget.streamCallback?.call(newStream);
              }
            },
            child: Text('${widget.isRunning ? 'Stop' : 'Start'} Measurement'),
          ),
        ),
      ],
    );
  }
}

class EdgeSelector extends StatefulWidget {
  final ValueChanged<EdgeType>? onChanged;
  final EdgeType defaultEdge;

  const EdgeSelector({
    super.key,
    this.onChanged,
    required this.defaultEdge,
  });

  @override
  State<EdgeSelector> createState() => _EdgeSelectorState();
}

class _EdgeSelectorState extends State<EdgeSelector> {
  late EdgeType edgeType = widget.defaultEdge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ToggleButton(
          checked: edgeType == EdgeType.falling,
          onChanged: (newVal) {
            if(newVal) {
              setState(() {
                edgeType = EdgeType.falling;
              });
              widget.onChanged?.call(edgeType);
            }
          },
          child: const Icon(
            FluentIcons.down,
            size: 16,
          ),
        ),
        ToggleButton(
          checked: edgeType == EdgeType.rising,
          onChanged: (newVal) {
            if(newVal) {
              setState(() {
                edgeType = EdgeType.rising;
              });
              widget.onChanged?.call(edgeType);
            }
          },
          child: const Icon(
            FluentIcons.up,
            size: 16,
          ),
        ),
      ],
    );
  }
}

enum EdgeType {
  rising,
  falling;

  int setChannel(int channel) {
    if(this == EdgeType.rising) {
      return channel.abs();
    }
    else {
      return -channel.abs();
    }
  }
}

enum LaserFrequency {
  twenty(20),
  forty(40),
  eighty(80);
  
  const LaserFrequency(this.frequency);
  final int frequency;

  @override
  String toString() {
    return '$frequency MHz';
  }

  int get periodInPs => 1e6 ~/ frequency;
}