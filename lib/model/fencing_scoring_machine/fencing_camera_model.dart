import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// フェンシングカメラモデル
class FencingCameraModel extends ChangeNotifier with WidgetsBindingObserver {
  FencingCameraModel(CameraDescription camera) {
    camera = camera;
    cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
    );
    initializeControllerFuture =
        cameraController.initialize().catchError((Object e) {
      throw Exception;
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    cameraController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.paused) {
      cameraController.dispose();
    }

    if (state == AppLifecycleState.resumed) {
      final cameras = await availableCameras();
      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
      );
      initializeControllerFuture =
          cameraController.initialize().catchError((Object e) {
        throw Exception;
      });
      notifyListeners();
    }
  }

  /// ズームレベル設定
  Future<void> setZoomLevel() async {
    _maxZoomLevel = await cameraController.getMaxZoomLevel();
    _minZoomLevel = await cameraController.getMinZoomLevel();
    notifyListeners();
  }

  /// カメラディスクリプション
  late CameraDescription camera;

  /// カメラコントローラー
  late CameraController cameraController;

  /// カメラコントローラー初期化フューチャー
  late Future<void> initializeControllerFuture;

  /// 最小ズームレベル
  double _minZoomLevel = 0;

  /// 最小ズームレベルゲッター
  double get minZoomLevel => _minZoomLevel;

  /// 最大ズームレベル
  double _maxZoomLevel = 0;

  /// 最大ズームレベルゲッター
  double get maxZoomLevel => _maxZoomLevel;
}
