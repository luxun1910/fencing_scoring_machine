import 'dart:async';
import 'package:fencing_scoring_machine/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';

// フェンシングビデオ再生ページモデル
class FencingVideoPlayerModel extends ChangeNotifier {
  // ビデオファイルパス
  String? _videoFilePath;

  String? get videoFilePath => _videoFilePath;

  set videoFilePath(String? path) {
    _videoFilePath = path;
    notifyListeners();
  }

  Future<bool> saveVideoToGallery() async {
    final result = await GallerySaver.saveVideo(
      _videoFilePath!,
      albumName: AppConstants.albumName,
    );
    return result ?? false;
  }
}
