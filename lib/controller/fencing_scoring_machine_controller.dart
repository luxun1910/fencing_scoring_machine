import 'package:fencing_scoring_machine/model/camera_model.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine.dart';
import 'package:fencing_scoring_machine/model/settings.dart';
import 'package:fencing_scoring_machine/view/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:fencing_scoring_machine/controller/score_controller.dart';
import 'package:fencing_scoring_machine/controller/timer_controller.dart';
import 'package:fencing_scoring_machine/controller/video_controller.dart';

class FencingScoringMachineController with WidgetsBindingObserver {
  late final ScoreController scoreController;
  late final TimerController timerController;
  late final VideoController videoController;

  FencingScoringMachineController(FencingScoringMachine machine,
      CameraModel cameraModel, Settings settings) {
    scoreController = ScoreController(machine);
    timerController = TimerController(machine);
    videoController = VideoController(machine, cameraModel, settings);

    // WidgetsBindingObserverの登録
    WidgetsBinding.instance.addObserver(this);
  }

  // アプリのライフサイクル状態変化時に呼ばれるメソッド
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      timerController.stopTimer();
    }
  }

  // コントローラー破棄時の処理
  void dispose() {
    // WidgetsBindingObserverの登録解除
    WidgetsBinding.instance.removeObserver(this);
    // タイマーのクリーンアップ
    timerController.dispose();
  }

  // タイマーボタンを押下する
  void pushTimer() async {
    timerController.toggleTimer();
    await videoController.startRecording();
  }

  // 左側の選手のスコアを1増やす
  void leftScoreUp() {
    timerController.stopTimer();
    scoreController.leftScoreUp();
    videoController.stopRecording();
  }

  // 左側の選手のスコアを1減らす
  void leftScoreDown() {
    timerController.stopTimer();
    scoreController.leftScoreDown();
    videoController.stopRecording();
  }

  // 右側の選手のスコアを1増やす
  void rightScoreUp() {
    timerController.stopTimer();
    scoreController.rightScoreUp();
    videoController.stopRecording();
  }

  // 右側の選手のスコアを1減らす
  void rightScoreDown() {
    timerController.stopTimer();
    scoreController.rightScoreDown();
    videoController.stopRecording();
  }

  // ダブルヒット（両方の選手のスコアを増やす）
  void doubleHit() {
    timerController.stopTimer();
    scoreController.doubleHit();
    videoController.stopRecording();
  }

  // 左右の選手のスコアを0にし、残り時間を3分に戻す
  void resetAll() {
    timerController.stopTimer();
    scoreController.resetScores();
    videoController.stopRecording();
  }

  // 動画再生画面へ遷移する
  void moveToVideoPlayer(BuildContext context) {
    videoController.moveToVideoPlayer(context);
  }

  // 設定画面へ遷移する
  void moveToSettingsPage(BuildContext context) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SettingsScreen(),
    ));
  }

  // 現在の最新のビデオをギャラリーに保存する
  void saveVideoToGallery(BuildContext context, String videoFilePath) async {
    videoController.saveVideoToGallery(context, videoFilePath);
  }

  // 時間設定ダイアログを開く
  void openChangeTimeDialog(BuildContext context) {
    timerController.openChangeTimeDialog(context);
  }
}
