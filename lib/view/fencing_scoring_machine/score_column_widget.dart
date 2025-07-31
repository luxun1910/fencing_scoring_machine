import 'package:fencing_scoring_machine/controller/fencing_scoring_machine_controller.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine/fencing_scoring_machine_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Score display column widget
class ScoreColumnWidget extends StatelessWidget {
  final bool isLeftSide;
  final Color scoreColor;
  final double scoreTextSize;
  final double buttonTextSize;
  final double height;

  const ScoreColumnWidget({
    super.key,
    required this.isLeftSide,
    required this.scoreColor,
    required this.scoreTextSize,
    required this.buttonTextSize,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final machine = context.watch<FencingScoringMachineModel>();
    final score = isLeftSide ? machine.leftScore : machine.rightScore;

    const Size maxSize = Size(double.maxFinite, double.maxFinite);
    const String plus = "+";
    const String minus = "-";

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Score Display
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Text(
                score.toString(),
                style: TextStyle(fontSize: scoreTextSize, color: scoreColor),
              ),
            ),
          ),
          // Score Up Button
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, height * 0.01),
              child: ElevatedButton(
                  onPressed: () {
                    if (isLeftSide) {
                      context
                          .read<FencingScoringMachineController>()
                          .leftScoreUp();
                    } else {
                      context
                          .read<FencingScoringMachineController>()
                          .rightScoreUp();
                    }
                  },
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
                  child: Text(
                    plus,
                    style: TextStyle(fontSize: buttonTextSize),
                  )),
            ),
          ),
          // Score Down Button
          Expanded(
            flex: 1,
            child: ElevatedButton(
                onPressed: () {
                  if (isLeftSide) {
                    context
                        .read<FencingScoringMachineController>()
                        .leftScoreDown();
                  } else {
                    context
                        .read<FencingScoringMachineController>()
                        .rightScoreDown();
                  }
                },
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
                )),
          ),
        ],
      ),
    );
  }
}
