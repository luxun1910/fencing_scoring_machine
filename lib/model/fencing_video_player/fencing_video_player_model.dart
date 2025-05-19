import 'dart:async';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:fencing_scoring_machine/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:video_player/video_player.dart';

/// フェンシングビデオ再生ページモデル
class FencingVideoPlayerModel extends ChangeNotifier {
  /// ビデオファイルパス
  String? _videoFilePath;

  /// ビデオファイルパスゲッター
  String? get videoFilePath => _videoFilePath;

  /// Chewieビデオコントローラー
  late ChewieController chewieController;

  /// Chewieビデオコントローラー初期化フラグ
  bool _isChewieControllerInitialized = false;

  /// Chewieビデオコントローラー初期化フラグゲッター
  bool get isChewieControllerInitialized => _isChewieControllerInitialized;

  /// ビデオコントローラー
  late VideoPlayerController _videoPlayerController;

  /// ビデオコントローラーゲッター
  VideoPlayerController get videoPlayerController => _videoPlayerController;

  /// ビデオコントローラーセッター
  set videoPlayerController(VideoPlayerController videoPlayerController) {
    _videoPlayerController = videoPlayerController;
    notifyListeners();
  }

  /// ビデオファイルパスセッター
  set videoFilePath(String? path) {
    _videoFilePath = path;
    notifyListeners();
  }

  /// コントローラー初期化
  void initControllers() {
    _isChewieControllerInitialized = false;
    _videoPlayerController = VideoPlayerController.file(File(videoFilePath!));

    // 正確なアスペクト比を取得するため、VideoPlayerControllerが初期化された後にChewieControllerの設定を行う
    _videoPlayerController.initialize().then((_) {
      chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: false,
        looping: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.blue,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightGreen,
        ),
        placeholder: Container(
          color: Colors.grey,
        ),
        autoInitialize: true,
      );
      _isChewieControllerInitialized = true;
      notifyListeners();
    });
  }

  /// ビデオをローカルに保存
  Future<bool> saveVideoToGallery() async {
    final result = await GallerySaver.saveVideo(
      _videoFilePath!,
      albumName: AppConstants.albumName,
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    chewieController.dispose();
    _isChewieControllerInitialized = false;
    notifyListeners();
    super.dispose();
  }
}
