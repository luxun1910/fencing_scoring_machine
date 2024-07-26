import 'package:fencing_scoring_machine/controller/fencing_scoring_machine_controller.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine.dart';
import 'package:fencing_scoring_machine/model/settings.dart';
import 'package:fencing_scoring_machine/view/banner_ad_page.dart';
import 'package:fencing_scoring_machine/view/fencing_camera_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FencingScoringMachinePage extends StatelessWidget {
  const FencingScoringMachinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final machine = context.watch<FencingScoringMachine>();
    final settings = context.watch<Settings>();
    final width = MediaQuery.of(context).size.width -
        MediaQuery.of(context).padding.left -
        MediaQuery.of(context).padding.right;
    final height = (MediaQuery.of(context).size.height -
            AppBar().preferredSize.height -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom) *
        0.98;

    final orientation = MediaQuery.of(context).orientation;

    late double scoreTextSize = height > width ? width * 0.3 : height * 0.3;
    if (scoreTextSize > 90) {
      scoreTextSize = 90;
    }

    const Size maxSize = Size(double.maxFinite, double.maxFinite);

    final double buttonTextSize = height > width ? width * 0.15 : height * 0.15;

    const String plus = "+";

    const String minus = "-";

    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: width,
              height: height,
              child: Column(
                children: [
                  if (settings.isVideoEnable &&
                      orientation == Orientation.portrait)
                    Expanded(
                        flex: settings.videoPreviewSize,
                        child: const FencingCameraPage()),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (settings.isVideoEnable &&
                            settings.videoPreviewPositionWhenLandscape ==
                                Position.left &&
                            orientation == Orientation.landscape)
                          Expanded(
                              flex: settings.videoPreviewSize,
                              child: const FencingCameraPage()),
                        // Left Column
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Left Score
                              Expanded(
                                flex: 1,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: Text(
                                    machine.leftScore.toString(),
                                    style: TextStyle(
                                        fontSize: scoreTextSize,
                                        color: Colors.red),
                                  ),
                                ),
                              ),
                              // Left ScoreUp Button
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, height * 0.01),
                                  child: ElevatedButton(
                                      onPressed: () => context
                                          .read<
                                              FencingScoringMachineController>()
                                          .leftScoreUp(),
                                      style: TextButton.styleFrom(
                                        fixedSize: maxSize,
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(24, 0, 24, 0),
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      child: Text(
                                        plus,
                                        style:
                                            TextStyle(fontSize: buttonTextSize),
                                      )),
                                ),
                              ),
                              // Left Scoredown Button
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                    onPressed: () => context
                                        .read<FencingScoringMachineController>()
                                        .leftScoreDown(),
                                    style: TextButton.styleFrom(
                                      fixedSize: maxSize,
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: FittedBox(
                                      child: Text(
                                        minus,
                                        style:
                                            TextStyle(fontSize: buttonTextSize),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ),
                        // Middle Column
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                width * 0.01, 0, width * 0.01, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (!machine.isTimerStarting) {
                                        context
                                            .read<
                                                FencingScoringMachineController>()
                                            .openChangeTimeDialog(context);
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
                                if (settings.isDoubleButtonEnable)
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0, 0, 0, height * 0.01),
                                      child: ElevatedButton(
                                        onPressed: () => {
                                          context
                                              .read<
                                                  FencingScoringMachineController>()
                                              .doubleHit(),
                                        },
                                        style: TextButton.styleFrom(
                                          fixedSize: const Size(
                                              double.maxFinite,
                                              double.maxFinite),
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(24, 0, 24, 0),
                                          textStyle: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .doubleButtonText),
                                      ),
                                    ),
                                  ),
                                // Start/Stop Button
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0, 0, 0, height * 0.01),
                                    child: ElevatedButton(
                                      onPressed: () => {
                                        context
                                            .read<
                                                FencingScoringMachineController>()
                                            .pushTimer(),
                                      },
                                      style: TextButton.styleFrom(
                                        fixedSize: maxSize,
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(24, 0, 24, 0),
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        backgroundColor: machine.isTimerStarting
                                            ? Colors.red
                                            : Colors.green,
                                        elevation: 3,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      child: Text(
                                        '${AppLocalizations.of(context)!.startStopButtonText}${const String.fromEnvironment('appNamePrefix')}',
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: ElevatedButton(
                                    onPressed: () => context
                                        .read<FencingScoringMachineController>()
                                        .resetAll(),
                                    style: TextButton.styleFrom(
                                      fixedSize: maxSize,
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              24, 0, 24, 0),
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: Text(AppLocalizations.of(context)!
                                        .resetButtonText),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Right Column
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Right Score
                              Expanded(
                                flex: 1,
                                child: FittedBox(
                                  fit: BoxFit.fill,
                                  child: Text(
                                    machine.rightScore.toString(),
                                    style: TextStyle(
                                        fontSize: scoreTextSize,
                                        color: Colors.green),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 0, height * 0.01),
                                  child: ElevatedButton(
                                    onPressed: () => context
                                        .read<FencingScoringMachineController>()
                                        .rightScoreUp(),
                                    style: TextButton.styleFrom(
                                      fixedSize: maxSize,
                                      padding:
                                          const EdgeInsetsDirectional.fromSTEB(
                                              24, 0, 24, 0),
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    child: Text(
                                      plus,
                                      style:
                                          TextStyle(fontSize: buttonTextSize),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: ElevatedButton(
                                  onPressed: () => context
                                      .read<FencingScoringMachineController>()
                                      .rightScoreDown(),
                                  style: TextButton.styleFrom(
                                    fixedSize: maxSize,
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  child: FittedBox(
                                    child: Text(
                                      minus,
                                      style: TextStyle(fontSize: buttonTextSize),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (settings.isVideoEnable &&
                            settings.videoPreviewPositionWhenLandscape ==
                                Position.right &&
                            orientation == Orientation.landscape)
                          Expanded(
                              flex: settings.videoPreviewSize,
                              child: const FencingCameraPage()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        floatingActionButton: machine.isTimerStarting
            ? Container()
            : FloatingActionButton.small(
                onPressed: () {
                  context
                      .read<FencingScoringMachineController>()
                      .moveToSettingsPage(context);
                },
                child: const Icon(Icons.settings),
              ),
        bottomNavigationBar: const BannerAdPage(),
      ),
    );
  }
}
