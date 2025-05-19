import 'dart:async';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:video_player/video_player.dart';

// フェンシングビデオ再生ページモデル
class FencingVideoPlayerModel extends ChangeNotifier {
  // ビデオファイルパス
  String? _videoFilePath;

  String? get videoFilePath => _videoFilePath;

  late ChewieController chewieController;
  bool _isChewieControllerInitialized = false;

  bool get isChewieControllerInitialized => _isChewieControllerInitialized;

  late VideoPlayerController _videoPlayerController;

  VideoPlayerController get videoPlayerController => _videoPlayerController;

  set videoPlayerController(VideoPlayerController videoPlayerController) {
    _videoPlayerController = videoPlayerController;
    notifyListeners();
  }

  set videoFilePath(String? path) {
    _videoFilePath = path;
    notifyListeners();
  }

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

  Future<bool> saveVideoToGallery() async {
    final result = await GallerySaver.saveVideo(
      _videoFilePath!,
      albumName: 'fencing_video',
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }
}
