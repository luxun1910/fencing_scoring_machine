import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPageController extends ChangeNotifier {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;
  bool isInitialized = false;

  void initializePlayer(String videoPath) {
    videoPlayerController = VideoPlayerController.file(File(videoPath));

    videoPlayerController.initialize().then((_) {
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: videoPlayerController.value.aspectRatio,
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

      isInitialized = true;
      notifyListeners();
    });
  }

  void disposePlayer() {
    videoPlayerController.dispose();
    chewieController?.dispose();
    isInitialized = false;
  }
}
