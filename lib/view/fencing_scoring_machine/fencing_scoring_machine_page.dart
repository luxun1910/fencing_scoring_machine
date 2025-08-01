import 'package:fencing_scoring_machine/controller/fencing_scoring_machine_controller.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine/fencing_scoring_machine_page_model.dart';
import 'package:fencing_scoring_machine/model/settings/settings_page_model.dart';
import 'package:fencing_scoring_machine/view/banner_ad_widget.dart';
import 'package:fencing_scoring_machine/view/fencing_scoring_machine/widgets/fencing_camera_widget.dart';
import 'package:fencing_scoring_machine/view/fencing_scoring_machine/widgets/score_column_widget.dart';
import 'package:fencing_scoring_machine/view/fencing_scoring_machine/widgets/control_panel_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Fencing scoring machine page
class FencingScoringMachinePage extends StatelessWidget {
  const FencingScoringMachinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final machine = context.watch<FencingScoringMachinePageModel>();
    final settings = context.watch<SettingsPageModel>();
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
                        child: const FencingCameraWidget()),
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
                              child: const FencingCameraWidget()),

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
                              child: const FencingCameraWidget()),
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
        bottomNavigationBar: const BannerAdWidget(),
      ),
    );
  }
}
