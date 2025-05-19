import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 左右
enum Position {
  left(0),
  right(1);

  final int position;
  const Position(this.position);

  @override
  String toString() => position.toString();

  factory Position.fromNum(int num) {
    return values.firstWhere((e) => e.position == num);
  }
}

class SettingsModel extends ChangeNotifier {
  SettingsModel() {
    _loadSelectedOption();
  }

  // ビデオオートセーブ
  late bool _isVideoAutoSave = false;

  bool get isVideoAutoSave => _isVideoAutoSave;

  set isVideoAutoSave(bool isVideoAutoSave) {
    _isVideoAutoSave = isVideoAutoSave;
    notifyListeners();
  }

  // ビデオプレビューサイズ
  late int _videoPreviewSize = 2;

  int get videoPreviewSize => _videoPreviewSize;

  set videoPreviewSize(int size) {
    _videoPreviewSize = size;
    notifyListeners();
  }

  // ビデオオンオフ
  late bool _isVideoEnable = true;

  bool get isVideoEnable => _isVideoEnable;

  set isVideoEnable(bool isEnable) {
    _isVideoEnable = isEnable;
    notifyListeners();
  }

  // ドゥーブルボタンオンオフ
  late bool _isDoubleButtonEnable = true;

  bool get isDoubleButtonEnable => _isDoubleButtonEnable;

  set isDoubleButtonEnable(bool isEnable) {
    _isDoubleButtonEnable = isEnable;
    notifyListeners();
  }

  // 横持ち時のビデオプレビュー位置
  late Position _videoPreviewPositionWhenLandscape = Position.right;

  Position get videoPreviewPositionWhenLandscape =>
      _videoPreviewPositionWhenLandscape;

  set videoPreviewPositionWhenLandscape(Position position) {
    _videoPreviewPositionWhenLandscape = position;
    notifyListeners();
  }

  // オプション読み込み
  Future<void> _loadSelectedOption() async {
    final prefs = await SharedPreferences.getInstance();

    _isVideoAutoSave = prefs.getBool('isVideoAutoSave') ?? false;
    _videoPreviewSize = prefs.getInt('cameraPreviewSize') ?? 2;
    _isVideoEnable = prefs.getBool('isCameraEnable') ?? true;
    _isDoubleButtonEnable = prefs.getBool('isDoubleButtonEnable') ?? true;
    _videoPreviewPositionWhenLandscape = Position.fromNum(
        prefs.getInt('videoPreviewPositionWhenLandscape') ?? 1);
    notifyListeners();
  }

  Future<void> setIsVideoAutoSave(bool option) async {
    _isVideoAutoSave = option;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isVideoAutoSave', option);

    notifyListeners();
  }

  Future<void> setCameraPreviewSize(int size) async {
    _videoPreviewSize = size;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('cameraPreviewSize', size);

    notifyListeners();
  }

  Future<void> setVideoEnable(bool enable) async {
    _isVideoEnable = enable;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isCameraEnable', enable);

    notifyListeners();
  }

  Future<void> setDoubleButtonEnable(bool enable) async {
    _isDoubleButtonEnable = enable;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isDoubleButtonEnable', enable);

    notifyListeners();
  }

  Future<void> setVideoPreviewPositionWhenLandscape(Position location) async {
    _videoPreviewPositionWhenLandscape = location;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('videoPreviewPositionWhenLandscape', location.index);

    notifyListeners();
  }
}
