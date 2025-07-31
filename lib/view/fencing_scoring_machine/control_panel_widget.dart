import 'package:fencing_scoring_machine/controller/fencing_scoring_machine_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// コントロールパネルウィジェット
class ControlPanelWidget extends StatelessWidget {
  final String remainingTime;
  final bool isTimerStarting;
  final bool isDoubleButtonEnable;
  final double height;
  final double width;

  const ControlPanelWidget({
    super.key,
    required this.remainingTime,
    required this.isTimerStarting,
    required this.isDoubleButtonEnable,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    const Size maxSize = Size(double.maxFinite, double.maxFinite);

    return Expanded(
      child: Padding(
        padding:
            EdgeInsetsDirectional.fromSTEB(width * 0.01, 0, width * 0.01, 0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Timer Display
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  if (!isTimerStarting) {
                    context
                        .read<FencingScoringMachineController>()
                        .openChangeTimeDialog(context);
                  }
                },
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    remainingTime,
                  ),
                ),
              ),
            ),
            // Double Hit Button (conditional)
            if (isDoubleButtonEnable)
              Expanded(
                flex: 1,
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(0, 0, 0, height * 0.01),
                  child: ElevatedButton(
                    onPressed: () => {
                      context
                          .read<FencingScoringMachineController>()
                          .doubleHit(),
                    },
                    style: TextButton.styleFrom(
                      fixedSize: const Size(double.maxFinite, double.maxFinite),
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                      textStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.doubleButtonText),
                  ),
                ),
              ),
            // Start/Stop Button
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, height * 0.01),
                child: ElevatedButton(
                  onPressed: () => {
                    context.read<FencingScoringMachineController>().pushTimer(),
                  },
                  style: TextButton.styleFrom(
                    fixedSize: maxSize,
                    padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                    textStyle: const TextStyle(
                      color: Colors.white,
                    ),
                    backgroundColor:
                        isTimerStarting ? Colors.red : Colors.green,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    '${AppLocalizations.of(context)!.startStopButtonText}${const String.fromEnvironment('appNamePrefix')}',
                  ),
                ),
              ),
            ),
            // Reset Button
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () =>
                    context.read<FencingScoringMachineController>().resetAll(),
                style: TextButton.styleFrom(
                  fixedSize: maxSize,
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                  textStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.resetButtonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
