import 'package:fencing_scoring_machine/controller/fencing_scoring_machine_controller.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine/fencing_scoring_machine_model.dart';
import 'package:fencing_scoring_machine/model/settings_model.dart';
import 'package:fencing_scoring_machine/view/banner_ad_view.dart';
import 'package:fencing_scoring_machine/view/fencing_scoring_machine/fencing_camera_view.dart';
import 'package:fencing_scoring_machine/view/fencing_scoring_machine/score_column_widget.dart';
import 'package:fencing_scoring_machine/view/fencing_scoring_machine/control_panel_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Fencing scoring machine screen
class FencingScoringMachineView extends StatelessWidget {
  const FencingScoringMachineView({super.key});

  @override
  Widget build(BuildContext context) {
    final machine = context.watch<FencingScoringMachineModel>();
    final settings = context.watch<SettingsModel>();
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

    final double buttonTextSize = height > width ? width * 0.15 : height * 0.15;

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
                        child: const FencingCameraView()),
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
                              child: const FencingCameraView()),

                        // Left Score Column
                        ScoreColumnWidget(
                          isLeftSide: true,
                          scoreColor: Colors.red,
                          scoreTextSize: scoreTextSize,
                          buttonTextSize: buttonTextSize,
                          height: height,
                        ),

                        // Control Panel
                        ControlPanelWidget(
                          height: height,
                          width: width,
                        ),

                        // Right Score Column
                        ScoreColumnWidget(
                          isLeftSide: false,
                          scoreColor: Colors.green,
                          scoreTextSize: scoreTextSize,
                          buttonTextSize: buttonTextSize,
                          height: height,
                        ),

                        if (settings.isVideoEnable &&
                            settings.videoPreviewPositionWhenLandscape ==
                                Position.right &&
                            orientation == Orientation.landscape)
                          Expanded(
                              flex: settings.videoPreviewSize,
                              child: const FencingCameraView()),
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
        bottomNavigationBar: const BannerAdView(),
      ),
    );
  }
}
