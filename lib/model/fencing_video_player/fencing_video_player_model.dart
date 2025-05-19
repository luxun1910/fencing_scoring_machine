import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class FencingVideoPlayerModel extends ChangeNotifier {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  final String videoPath;

  VideoPlayerController get videoPlayerController => _videoPlayerController;
  ChewieController get chewieController => _chewieController;

  FencingVideoPlayerModel({required this.videoPath}) {
    _initControllers();
  }

  void _initControllers() {
    _videoPlayerController = VideoPlayerController.file(File(videoPath));
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9, // デフォルト値を設定し、後でアスペクト比を更新
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

    // 動画が初期化された後、正確なアスペクト比を設定
    _videoPlayerController.initialize().then((_) {
      _chewieController = ChewieController(
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
      notifyListeners();
    });
  }

  Future<bool> saveVideoToGallery() async {
    final result = await GallerySaver.saveVideo(
      videoPath,
      albumName: 'fencing_video',
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
