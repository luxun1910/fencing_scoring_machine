import 'package:fencing_scoring_machine/log_helper.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine.dart';

class ScoreController {
  final FencingScoringMachine _machine;

  ScoreController(this._machine);

  // 左側の選手のスコアを1増やす
  void leftScoreUp() {
    logger.d('左側の選手のスコアを1増やします');
    _machine.getLeftScoreUp();
  }

  // 左側の選手のスコアを1減らす
  void leftScoreDown() {
    logger.d('左側の選手のスコアを1減らします');
    _machine.getLeftScoreDown();
  }

  // 右側の選手のスコアを1増やす
  void rightScoreUp() {
    logger.d('右側の選手のスコアを1増やします');
    _machine.getRightScoreUp();
  }

  // 右側の選手のスコアを1減らす
  void rightScoreDown() {
    logger.d('右側の選手のスコアを1減らします');
    _machine.getRightScoreDown();
  }

  // ダブルヒット（両方の選手のスコアを増やす）
  void doubleHit() {
    logger.d('ダブルヒットします');
    _machine.getLeftScoreUp();
    _machine.getRightScoreUp();
  }

  // スコアをリセットする
  void resetScores() {
    logger.d('スコアをリセットします');
    _machine.resetAll();
  }
}
