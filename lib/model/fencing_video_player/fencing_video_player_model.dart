import 'dart:async';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:fencing_scoring_machine/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:video_player/video_player.dart';

/// Fencing video player page model
class FencingVideoPlayerModel extends ChangeNotifier {
  /// Video file path
  String? _videoFilePath;

  /// Video file path getter
  String? get videoFilePath => _videoFilePath;

  /// Chewie video controller
  late ChewieController chewieController;

  /// Chewie video controller initialization flag
  bool _isChewieControllerInitialized = false;

  /// Chewie video controller initialization flag getter
  bool get isChewieControllerInitialized => _isChewieControllerInitialized;

  /// Video controller
  late VideoPlayerController _videoPlayerController;

  /// Video controller getter
  VideoPlayerController get videoPlayerController => _videoPlayerController;

  /// Video controller setter
  set videoPlayerController(VideoPlayerController videoPlayerController) {
    _videoPlayerController = videoPlayerController;
    notifyListeners();
  }

  /// Video file path setter
  set videoFilePath(String? path) {
    _videoFilePath = path;
    notifyListeners();
  }

  /// Controller initialization
  void initControllers() {
    _isChewieControllerInitialized = false;
    _videoPlayerController = VideoPlayerController.file(File(videoFilePath!));

    // Set up ChewieController after VideoPlayerController initialization to get accurate aspect ratio
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

  /// Save video to local storage
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
