import 'package:fencing_scoring_machine/model/fencing_scoring_machine.dart';

class ScoreController {
  final FencingScoringMachine _machine;

  ScoreController(this._machine);

  // 左側の選手のスコアを1増やす
  void leftScoreUp() {
    _machine.getLeftScoreUp();
  }

  // 左側の選手のスコアを1減らす
  void leftScoreDown() {
    _machine.getLeftScoreDown();
  }

  // 右側の選手のスコアを1増やす
  void rightScoreUp() {
    _machine.getRightScoreUp();
  }

  // 右側の選手のスコアを1減らす
  void rightScoreDown() {
    _machine.getRightScoreDown();
  }

  // ダブルヒット（両方の選手のスコアを増やす）
  void doubleHit() {
    _machine.getLeftScoreUp();
    _machine.getRightScoreUp();
  }

  // スコアをリセットする
  void resetScores() {
    _machine.resetAll();
  }
}
