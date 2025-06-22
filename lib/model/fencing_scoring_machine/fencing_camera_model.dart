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
      // スライダーの位置を初期設定に戻す
      _sliderValue = 0.1;
      notifyListeners();
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

  /// スライダー値を更新
  void updateSliderValue(double value) {
    _sliderValue = value;
    final valueForZoom = value * 10;
    if (valueForZoom <= _maxZoomLevel && valueForZoom >= _minZoomLevel) {
      cameraController.setZoomLevel(valueForZoom);
    }
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

  /// スライダー値
  double _sliderValue = 0.1;

  /// スライダー値ゲッター
  double get sliderValue => _sliderValue;
}
