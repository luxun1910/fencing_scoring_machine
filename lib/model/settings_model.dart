import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Video preview position
enum Position {
  left(0),
  right(1);

  final int position;
  const Position(this.position);

  @override
  String toString() => position.toString();

  /// Get video preview position from number
  factory Position.fromNum(int num) {
    return values.firstWhere((e) => e.position == num);
  }
}

/// Settings screen model
class SettingsModel extends ChangeNotifier {
  SettingsModel() {
    _loadSelectedOption();
  }

  /// Video auto save
  late bool _isVideoAutoSave = false;

  /// Video auto-save getter
  bool get isVideoAutoSave => _isVideoAutoSave;

  /// Video auto-save setter
  set isVideoAutoSave(bool isVideoAutoSave) {
    _isVideoAutoSave = isVideoAutoSave;
    notifyListeners();
  }

  /// Video preview size
  late int _videoPreviewSize = 2;

  /// Video preview size getter
  int get videoPreviewSize => _videoPreviewSize;

  /// Video preview size setter
  set videoPreviewSize(int size) {
    _videoPreviewSize = size;
    notifyListeners();
  }

  /// Video on/off
  late bool _isVideoEnable = true;

  /// Video on/off getter
  bool get isVideoEnable => _isVideoEnable;

  /// Video on/off setter
  set isVideoEnable(bool isEnable) {
    _isVideoEnable = isEnable;
    notifyListeners();
  }

  /// Double button on/off
  late bool _isDoubleButtonEnable = true;

  /// Double button on/off getter
  bool get isDoubleButtonEnable => _isDoubleButtonEnable;

  /// Double button on/off setter
  set isDoubleButtonEnable(bool isEnable) {
    _isDoubleButtonEnable = isEnable;
    notifyListeners();
  }

  /// Match number count on/off
  late bool _isMatchNumberCountEnable = false;

  /// Match number count on/off getter
  bool get isMatchNumberCountEnable => _isMatchNumberCountEnable;

  /// Match number count on/off setter
  set isMatchNumberCountEnable(bool isEnable) {
    _isMatchNumberCountEnable = isEnable;
    notifyListeners();
  }

  /// Video preview position when landscape
  late Position _videoPreviewPositionWhenLandscape = Position.right;

  Position get videoPreviewPositionWhenLandscape =>
      _videoPreviewPositionWhenLandscape;

  set videoPreviewPositionWhenLandscape(Position position) {
    _videoPreviewPositionWhenLandscape = position;
    notifyListeners();
  }

  /// Load options
  Future<void> _loadSelectedOption() async {
    final prefs = await SharedPreferences.getInstance();

    _isVideoAutoSave = prefs.getBool('isVideoAutoSave') ?? false;
    _videoPreviewSize = prefs.getInt('cameraPreviewSize') ?? 2;
    _isVideoEnable = prefs.getBool('isCameraEnable') ?? true;
    _isDoubleButtonEnable = prefs.getBool('isDoubleButtonEnable') ?? true;
    _isMatchNumberCountEnable =
        prefs.getBool('isMatchNumberCountEnable') ?? false;
    _videoPreviewPositionWhenLandscape = Position.fromNum(
        prefs.getInt('videoPreviewPositionWhenLandscape') ?? 1);
    notifyListeners();
  }

  /// Video auto save on/off setting
  Future<void> setIsVideoAutoSave(bool option) async {
    _isVideoAutoSave = option;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isVideoAutoSave', option);

    notifyListeners();
  }

  /// Video preview size setting
  Future<void> setCameraPreviewSize(int size) async {
    _videoPreviewSize = size;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('cameraPreviewSize', size);

    notifyListeners();
  }

  /// Video on/off setting
  Future<void> setVideoEnable(bool enable) async {
    _isVideoEnable = enable;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isCameraEnable', enable);

    notifyListeners();
  }

  /// Double button on/off setting
  Future<void> setDoubleButtonEnable(bool enable) async {
    _isDoubleButtonEnable = enable;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isDoubleButtonEnable', enable);

    notifyListeners();
  }

  /// Match number count on/off setting
  Future<void> setMatchNumberCountEnable(bool enable) async {
    _isMatchNumberCountEnable = enable;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isMatchNumberCountEnable', enable);

    notifyListeners();
  }

  /// Video preview position setting when landscape
  Future<void> setVideoPreviewPositionWhenLandscape(Position location) async {
    _videoPreviewPositionWhenLandscape = location;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('videoPreviewPositionWhenLandscape', location.index);

    notifyListeners();
  }
}
