import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fencing_scoring_machine/log_helper.dart';
import 'package:fencing_scoring_machine/model/camera_model.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine.dart';
import 'package:fencing_scoring_machine/model/settings.dart';
import 'package:fencing_scoring_machine/view/fencing_video_page.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';

class VideoController {
  final FencingScoringMachine _machine;
  final CameraModel _cameraModel;
  final Settings _settings;

  VideoController(this._machine, this._cameraModel, this._settings);

  // 録画を開始する
  Future<void> startRecording() async {
    if (!_settings.isVideoEnable) {
      return;
    }

    try {
      if (!_cameraModel.cameraController.value.isInitialized) {
        logger.e("カメラが初期化できていません。");
        return;
      }

      // すでに録画中なら何もしない
      if (_cameraModel.cameraController.value.isRecordingVideo) {
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

  // 録画を停止する
  Future<void> stopRecording() async {
    if (!_settings.isVideoEnable) {
      return;
    }

    if (!_cameraModel.cameraController.value.isRecordingVideo) {
      return;
    }

    logger.d("動画撮影終了");
    try {
      var video = await _cameraModel.cameraController.stopVideoRecording();
      _setCurrentLatestVideoPath(video.path);
    } catch (e) {
      logger.e("録画停止エラー: $e", error: e);
    }
  }

  // 最新のビデオパスを保存
  void _setCurrentLatestVideoPath(String xfileVideoPath) {
    if (_settings.isVideoAutoSave) {
      GallerySaver.saveVideo(xfileVideoPath, albumName: 'fencing_video');
    }

    // 既存のビデオを全て削除（最新以外）
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
    _machine.latestVideoPath = xfileVideoPath;
  }

  // 動画再生画面へ遷移する
  void moveToVideoPlayer(BuildContext context) async {
    if (_machine.latestVideoPath != null &&
        _machine.latestVideoPath!.isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            VideoPlayerScreen(videoPath: _machine.latestVideoPath!),
      ));
    }
  }

  // 現在の最新のビデオをギャラリーに保存する
  Future<void> saveVideoToGallery(
      BuildContext context, String videoFilePath) async {
    final result =
        await GallerySaver.saveVideo(videoFilePath, albumName: 'fencing_video');
    if (result == true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('動画の保存に成功しました！'),
          ),
        );
      }
    }
  }
}
