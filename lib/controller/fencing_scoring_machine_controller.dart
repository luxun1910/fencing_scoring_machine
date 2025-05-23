import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fencing_scoring_machine/app_constants.dart';
import 'package:fencing_scoring_machine/log_helper.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine/fencing_camera_model.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine/fencing_scoring_machine_model.dart';
import 'package:fencing_scoring_machine/model/fencing_video_player/fencing_video_player_model.dart';
import 'package:fencing_scoring_machine/model/settings_model.dart';
import 'package:fencing_scoring_machine/view/fencing_video_player/fencing_video_player_view.dart';
import 'package:fencing_scoring_machine/view/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

/// フェンシング審判機コントローラー
class FencingScoringMachineController extends WidgetsBindingObserver {
  FencingScoringMachineController(
      FencingScoringMachineModel machine,
      FencingCameraModel cameraModel,
      SettingsModel settings,
      FencingVideoPlayerModel videoPlayerModel) {
    _machine = machine;
    _settings = settings;
    _cameraModel = cameraModel;
    _videoPlayerModel = videoPlayerModel;

    WidgetsBinding.instance.addObserver(this);
  }

  /// フェンシング審判機モデル
  late FencingScoringMachineModel _machine;

  /// 設定モデル
  late SettingsModel _settings;

  /// フェンシングカメラモデル
  late FencingCameraModel _cameraModel;

  /// フェンシングビデオプレイヤーモデル
  late FencingVideoPlayerModel _videoPlayerModel;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _stopTimer();
    }
  }

  /// タイマーボタンを押下する
  void pushTimer() async {
    if (!_machine.isTimerStarting) {
      // タイマースタート
      _machine.isTimerStarting = true;
      _machine.timer = Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) {
          _machine.minusSeconds();
        },
      );
    } else {
      _stopTimer();
    }

    // 動画撮影関係
    if (_settings.isVideoEnable) {
      try {
        //カメラの初期化がなされていない場合抜ける
        if (!_cameraModel.cameraController.value.isInitialized) {
          logger.e("初期化ができていません。");
          return;
        }
        //すでにカメラの録画が始まっている際には録画をストップしてjavaをcall
        if (_cameraModel.cameraController.value.isRecordingVideo) {
          _stopRecording();
          return;
        }
        try {
          await _cameraModel.cameraController.prepareForVideoRecording();
          await _cameraModel.cameraController.startVideoRecording();
          logger.d("動画撮影開始");
        } on CameraException catch (e) {
          logger.e("動画撮影ができません", error: e);
        }
      } catch (e) {
        logger.e(e.toString(), error: e);
      }
    }
  }

  /// タイマー停止
  void _stopTimer() {
    _machine.isTimerStarting = false;
    _machine.timer?.cancel();
  }

  /// 動画撮影停止
  void _stopRecording() async {
    if (_settings.isVideoEnable) {
      logger.d("動画撮影終了");
      //カメラを止める＆保存
      var video = await _cameraModel.cameraController.stopVideoRecording();
      _setCurrentLatestVideoFilePath(video.path);
    }
  }

  /// 左側の選手のスコアを1増やす
  void leftScoreUp() {
    _stopTimer();
    _machine.getLeftScoreUp();
    if (_cameraModel.cameraController.value.isRecordingVideo) {
      _stopRecording();
    }
  }

  /// 左側の選手のスコアを1減らす
  void leftScoreDown() {
    _stopTimer();
    _machine.getLeftScoreDown();
    if (_cameraModel.cameraController.value.isRecordingVideo) {
      _stopRecording();
    }
  }

  /// 右側の選手のスコアを1増やす
  void rightScoreUp() {
    _stopTimer();
    _machine.getRightScoreUp();
    if (_cameraModel.cameraController.value.isRecordingVideo) {
      _stopRecording();
    }
  }

  /// 右側の選手のスコアを1減らす
  void rightScoreDown() {
    _stopTimer();
    _machine.getRightScoreDown();
    if (_cameraModel.cameraController.value.isRecordingVideo) {
      _stopRecording();
    }
  }

  void doubleHit() {
    _stopTimer();
    _machine.getLeftScoreUp();
    _machine.getRightScoreUp();
    if (_cameraModel.cameraController.value.isRecordingVideo) {
      _stopRecording();
    }
  }

  /// 左右の選手のスコアを0にし、残り時間を3分に戻す
  void resetAll() {
    _stopTimer();
    _machine.resetAll();
    if (_cameraModel.cameraController.value.isRecordingVideo) {
      _stopRecording();
    }
  }

  /// 最新のビデオファイルパスを保存
  void _setCurrentLatestVideoFilePath(String xfileVideoPath) {
    if (_settings.isVideoAutoSave) {
      GallerySaver.saveVideo(xfileVideoPath, albumName: AppConstants.albumName);
    }

    /// 既存のビデオを全て削除
    var xfileVideoDir = File(xfileVideoPath).parent;
    xfileVideoDir
        .listSync()
        .where((element) => element.path.endsWith('.mp4'))
        .forEach((fileEntity) {
      if (fileEntity.path != xfileVideoPath) {
        fileEntity.deleteSync();
      }
    });

    // 最新のビデオパスを保存
    _machine.latestVideoFilePath = xfileVideoPath;
  }

  /// ビデオ再生画面へ遷移する
  void moveToVideoPlayer(BuildContext context) {
    if (_machine.latestVideoFilePath != null &&
        _machine.latestVideoFilePath!.isNotEmpty) {
      _videoPlayerModel.videoFilePath = _machine.latestVideoFilePath!;
      _videoPlayerModel.initControllers();
      Navigator.of(context)
          .push(MaterialPageRoute(
        builder: (context) => const FencingVideoPlayerView(),
      ))
          .then((_) {
        _videoPlayerModel.chewieController.dispose();
        _videoPlayerModel.videoPlayerController.dispose();
      });
    }
  }

  /// 設定画面へ遷移する
  void moveToSettingsPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SettingsView(),
    ));
  }

  /// タイマー設定画面を開く
  void openChangeTimeDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    var minutes = _machine.secondsLeft ~/ 60;
    var seconds = _machine.secondsLeft - minutes * 60;

    int dropdownValue1 = minutes;
    int dropdownValue2 = seconds;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Timer Setting"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      child: DropdownButtonFormField<int>(
                        value: dropdownValue1,
                        hint: const Text('数字を選択'),
                        items: List<int>.generate(4, (i) => i).map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          dropdownValue1 = (newValue) as int;
                        },
                        validator: (value) {
                          if (value == null) {
                            return '数字を選択してください';
                          }
                          return null;
                        },
                      ),
                    ),
                    Flexible(
                      child: DropdownButtonFormField<int>(
                        value: dropdownValue2,
                        hint: const Text('数字を選択'),
                        items:
                            List<int>.generate(60, (i) => i).map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString().padLeft(2, '0')),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          dropdownValue2 = (newValue) as int;
                        },
                        validator: (value) {
                          if (value == null) {
                            return '数字を選択してください';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      _machine.secondsLeft =
                          dropdownValue1 * 60 + dropdownValue2;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('The remaining time has changed!')),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
