import 'dart:async';

import 'package:fencing_scoring_machine/controller/score_controller.dart';
import 'package:fencing_scoring_machine/controller/video_controller.dart';
import 'package:fencing_scoring_machine/log_helper.dart';
import 'package:fencing_scoring_machine/model/camera_model.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine.dart';
import 'package:fencing_scoring_machine/model/settings.dart';
import 'package:fencing_scoring_machine/view/settings/settings_page.dart';
import 'package:flutter/material.dart';

class FencingScoringMachineController with WidgetsBindingObserver {
  late final FencingScoringMachine machine;
  late final ScoreController scoreController;
  late final VideoController videoController;

  FencingScoringMachineController(FencingScoringMachine machine,
      CameraModel cameraModel, Settings settings) {
    machine = machine;
    scoreController = ScoreController(machine);
    videoController = VideoController(machine, cameraModel, settings);

    // WidgetsBindingObserverの登録
    WidgetsBinding.instance.addObserver(this);
  }

  // アプリのライフサイクル状態変化時に呼ばれるメソッド
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      stopTimer();
    }
  }

  // コントローラー破棄時の処理
  void dispose() {
    // WidgetsBindingObserverの登録解除
    WidgetsBinding.instance.removeObserver(this);
    stopTimer();
  }

  // タイマーボタンを押下する
  void pushTimer() async {
    toggleTimer();
    await videoController.startRecording();
  }

  // 左側の選手のスコアを1増やす
  void leftScoreUp() {
    stopTimer();
    scoreController.leftScoreUp();
    videoController.stopRecording();
  }

  // 左側の選手のスコアを1減らす
  void leftScoreDown() {
    stopTimer();
    scoreController.leftScoreDown();
    videoController.stopRecording();
  }

  // 右側の選手のスコアを1増やす
  void rightScoreUp() {
    stopTimer();
    scoreController.rightScoreUp();
    videoController.stopRecording();
  }

  // 右側の選手のスコアを1減らす
  void rightScoreDown() {
    stopTimer();
    scoreController.rightScoreDown();
    videoController.stopRecording();
  }

  // ダブルヒット（両方の選手のスコアを増やす）
  void doubleHit() {
    stopTimer();
    scoreController.doubleHit();
    videoController.stopRecording();
  }

  // 左右の選手のスコアを0にし、残り時間を3分に戻す
  void resetAll() {
    stopTimer();
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

  // タイマーを開始または停止する
  void toggleTimer() {
    if (!machine.isTimerStarting) {
      startTimer();
    } else {
      stopTimer();
    }
  }

  // タイマーを開始する
  void startTimer() {
    logger.d('タイマーを開始します');
    machine.isTimerStarting = true;
    machine.timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        machine.minusSeconds();
      },
    );
  }

  // タイマーを停止する
  void stopTimer() {
    logger.d('タイマーを停止します');
    machine.isTimerStarting = false;
    machine.timer?.cancel();
  }

  // 時間を設定する
  void setTime(int seconds) {
    logger.d('時間を設定します');
    stopTimer();
    machine.secondsLeft = seconds;
  }

  // ダイアログを表示して時間を変更する
  void openChangeTimeDialog(BuildContext context) {
    if (machine.isTimerStarting) {
      return;
    }

    final formKey = GlobalKey<FormState>();
    int? minutes;
    int? seconds;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('時間設定'),
          content: Form(
            key: formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: '分'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => minutes = int.tryParse(value ?? ''),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '分を入力してください';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: '秒'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => seconds = int.tryParse(value ?? ''),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '秒を入力してください';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final totalSeconds = (minutes ?? 0) * 60 + (seconds ?? 0);
                  setTime(totalSeconds);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('設定'),
            ),
          ],
        );
      },
    );
  }
}
