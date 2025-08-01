import 'package:fencing_scoring_machine/app_constants.dart';
import 'package:fencing_scoring_machine/controller/fencing_scoring_machine_controller.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine/fencing_scoring_machine_page_model.dart';
import 'package:fencing_scoring_machine/model/settings/settings_page_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Control panel widget
class ControlPanelWidget extends StatelessWidget {
  final double height;
  final double width;

  const ControlPanelWidget({
    super.key,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final machine = context.watch<FencingScoringMachinePageModel>();
    final settings = context.watch<SettingsPageModel>();
    final controller = context.watch<FencingScoringMachineController>();

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
                  if (!machine.isTimerStarting) {
                    controller.openChangeTimeDialog(context);
                  }
                },
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    machine.remainingTime,
                  ),
                ),
              ),
            ),
            // Matchup Text(Optional)
            if (settings.isMatchNumberCountEnable)
              Text(
                AppConstants.matchUpPatterns[machine.matchNumber]!,
                style: const TextStyle(color: Colors.blueAccent),
              ),

            // Match Number Counter(Optional)
            if (settings.isMatchNumberCountEnable)
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    if (!machine.isTimerStarting) {
                      controller.openChangeMatchNumberDialog(context);
                    }
                  },
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      style: const TextStyle(color: Colors.orangeAccent),
                      '${machine.matchNumber} Set',
                    ),
                  ),
                ),
              ),
            // Match Number Count Button(Optional)
            if (settings.isMatchNumberCountEnable)
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.decreaseMatchNumber();
                          },
                          child: const Text('-'),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.increaseMatchNumber();
                          },
                          child: const Text('+'),
                        ),
                      ),
                    ],
                  )),
            // Double Hit Button (conditional)
            if (settings.isDoubleButtonEnable)
              Expanded(
                flex: 1,
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(0, 0, 0, height * 0.01),
                  child: ElevatedButton(
                    onPressed: () => {
                      controller.doubleHit(),
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
                    controller.pushTimer(),
                  },
                  style: TextButton.styleFrom(
                    fixedSize: maxSize,
                    padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                    textStyle: const TextStyle(
                      color: Colors.white,
                    ),
                    backgroundColor:
                        machine.isTimerStarting ? Colors.red : Colors.green,
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
                onPressed: () => controller.resetAll(),
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
