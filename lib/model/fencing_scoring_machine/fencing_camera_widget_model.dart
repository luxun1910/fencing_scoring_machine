import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Fencing camera widget model
class FencingCameraWidgetModel extends ChangeNotifier
    with WidgetsBindingObserver {
  FencingCameraWidgetModel(CameraDescription camera) {
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
      // Reset slider position to default
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

  /// Zoom level setting
  Future<void> setZoomLevel() async {
    _maxZoomLevel = await cameraController.getMaxZoomLevel();
    _minZoomLevel = await cameraController.getMinZoomLevel();
    notifyListeners();
  }

  /// Update slider value
  void updateSliderValue(double value) {
    _sliderValue = value;
    final valueForZoom = value * 10;
    if (valueForZoom <= _maxZoomLevel && valueForZoom >= _minZoomLevel) {
      cameraController.setZoomLevel(valueForZoom);
    }
    notifyListeners();
  }

  /// Camera description
  late CameraDescription camera;

  /// Camera controller
  late CameraController cameraController;

  /// Camera controller initialization future
  late Future<void> initializeControllerFuture;

  /// Minimum zoom level
  double _minZoomLevel = 0;

  /// Minimum zoom level getter
  double get minZoomLevel => _minZoomLevel;

  /// Maximum zoom level
  double _maxZoomLevel = 0;

  /// Maximum zoom level getter
  double get maxZoomLevel => _maxZoomLevel;

  /// Slider value
  double _sliderValue = 0.1;

  /// Slider value getter
  double get sliderValue => _sliderValue;
}
