import 'package:fluent_ui/fluent_ui.dart';
import 'package:tt_bindings/tt_bindings.dart';

class ProcessingInput extends StatefulWidget {
  final int laserPeriod;
  final PostProcessingParams initialParams;
  final ValueChanged<PostProcessingParams> processingParamsCallback;

  const ProcessingInput({
    super.key,
    required this.laserPeriod,
    required this.initialParams,
    required this.processingParamsCallback,
  });

  @override
  State<ProcessingInput> createState() => _ProcessingInputState();
}

class _ProcessingInputState extends State<ProcessingInput> {
  late double integrationTimeSeconds = widget.initialParams.integrationTimePs / 1e12;
  late GatingRange gatingRange = widget.initialParams.gatingRange;
  late int activeChannel = widget.initialParams.activeChannel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Integration Time (s):'),
                  SizedBox(
                    width: 100,
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
                      clearButton: false,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Gate Range (ps):'),
                  SizedBox(
                    width: 100,
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
                      clearButton: false,
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: NumberBox(
                      value: gatingRange.endPs,
                      onChanged: (val) {
                        if(val != null) {
                          gatingRange = GatingRange(gatingRange.startPs, val);
                        }
                      },
                      min: gatingRange.startPs,
                      max: widget.laserPeriod,
                      mode: SpinButtonPlacementMode.none,
                      clearButton: false,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Display Channel:'),
                  SizedBox(
                    width: 100,
                    child: NumberBox(
                      value: activeChannel,
                      onChanged: (val) {
                        if(val != null) {
                          activeChannel = val;
                        }
                      },
                      smallChange: 1,
                      largeChange: 5,
                      min: 1,
                      max: 8,
                      mode: SpinButtonPlacementMode.inline,
                      clearButton: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Button(
            onPressed: () {
              widget.processingParamsCallback(
                PostProcessingParams(
                  integrationTimeSeconds: integrationTimeSeconds,
                  gatingRange: gatingRange,
                  activeChannel: activeChannel,
                ),
              );
            },
            child: const Text('Update Processing Params'),
          ),
        ),
      ],
    );
  }
}