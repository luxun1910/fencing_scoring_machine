import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ビデオプレビュー位置
enum Position {
  left(0),
  right(1);

  final int position;
  const Position(this.position);

  @override
  String toString() => position.toString();

  /// 数値からビデオプレビュー位置を取得する
  factory Position.fromNum(int num) {
    return values.firstWhere((e) => e.position == num);
  }
}

/// 設定画面モデル
class SettingsModel extends ChangeNotifier {
  SettingsModel() {
    _loadSelectedOption();
  }

  /// ビデオオートセーブ
  late bool _isVideoAutoSave = false;

  /// ビデオオートセーブゲッター
  bool get isVideoAutoSave => _isVideoAutoSave;

  /// ビデオオートセーブセッター
  set isVideoAutoSave(bool isVideoAutoSave) {
    _isVideoAutoSave = isVideoAutoSave;
    notifyListeners();
  }

  /// ビデオプレビューサイズ
  late int _videoPreviewSize = 2;

  /// ビデオプレビューサイズゲッター
  int get videoPreviewSize => _videoPreviewSize;

  /// ビデオプレビューサイズセッター
  set videoPreviewSize(int size) {
    _videoPreviewSize = size;
    notifyListeners();
  }

  /// ビデオオンオフ
  late bool _isVideoEnable = true;

  /// ビデオオンオフゲッター
  bool get isVideoEnable => _isVideoEnable;

  /// ビデオオンオフセッター
  set isVideoEnable(bool isEnable) {
    _isVideoEnable = isEnable;
    notifyListeners();
  }

  /// ドゥーブルボタンオンオフ
  late bool _isDoubleButtonEnable = true;

  /// ドゥーブルボタンオンオフゲッター
  bool get isDoubleButtonEnable => _isDoubleButtonEnable;

  /// ドゥーブルボタンオンオフセッター
  set isDoubleButtonEnable(bool isEnable) {
    _isDoubleButtonEnable = isEnable;
    notifyListeners();
  }

  /// セット数カウントオンオフ
  late bool _isSetCountEnable = false;

  /// セット数カウントオンオフゲッター
  bool get isSetCountEnable => _isSetCountEnable;

  /// セット数カウントオンオフセッター
  set isSetCountEnable(bool isEnable) {
    _isSetCountEnable = isEnable;
    notifyListeners();
  }

  /// 横持ち時のビデオプレビュー位置
  late Position _videoPreviewPositionWhenLandscape = Position.right;

  Position get videoPreviewPositionWhenLandscape =>
      _videoPreviewPositionWhenLandscape;

  set videoPreviewPositionWhenLandscape(Position position) {
    _videoPreviewPositionWhenLandscape = position;
    notifyListeners();
  }

  /// オプション読み込み
  Future<void> _loadSelectedOption() async {
    final prefs = await SharedPreferences.getInstance();

    _isVideoAutoSave = prefs.getBool('isVideoAutoSave') ?? false;
    _videoPreviewSize = prefs.getInt('cameraPreviewSize') ?? 2;
    _isVideoEnable = prefs.getBool('isCameraEnable') ?? true;
    _isDoubleButtonEnable = prefs.getBool('isDoubleButtonEnable') ?? true;
    _isSetCountEnable = prefs.getBool('isSetCountEnable') ?? false;
    _videoPreviewPositionWhenLandscape = Position.fromNum(
        prefs.getInt('videoPreviewPositionWhenLandscape') ?? 1);
    notifyListeners();
  }

  /// ビデオオートセーブオンオフ設定
  Future<void> setIsVideoAutoSave(bool option) async {
    _isVideoAutoSave = option;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isVideoAutoSave', option);

    notifyListeners();
  }

  /// ビデオプレビューサイズ設定
  Future<void> setCameraPreviewSize(int size) async {
    _videoPreviewSize = size;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('cameraPreviewSize', size);

    notifyListeners();
  }

  /// ビデオオンオフ設定
  Future<void> setVideoEnable(bool enable) async {
    _isVideoEnable = enable;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isCameraEnable', enable);

    notifyListeners();
  }

  /// ドゥーブルボタンオンオフ設定
  Future<void> setDoubleButtonEnable(bool enable) async {
    _isDoubleButtonEnable = enable;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isDoubleButtonEnable', enable);

    notifyListeners();
  }

  /// セット数カウントオンオフ設定
  Future<void> setSetCountEnable(bool enable) async {
    _isSetCountEnable = enable;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isSetCountEnable', enable);

    notifyListeners();
  }

  /// 横持ち時のビデオプレビュー位置設定
  Future<void> setVideoPreviewPositionWhenLandscape(Position location) async {
    _videoPreviewPositionWhenLandscape = location;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('videoPreviewPositionWhenLandscape', location.index);

    notifyListeners();
  }
}
