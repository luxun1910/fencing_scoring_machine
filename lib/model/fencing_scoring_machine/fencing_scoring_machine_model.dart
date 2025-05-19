import 'dart:async';
import 'package:flutter/material.dart';

/// フェンシング審判機モデル
class FencingScoringMachineModel extends ChangeNotifier
    with WidgetsBindingObserver {
  FencingScoringMachineModel() {
    WidgetsBinding.instance.addObserver(this);
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 左側選手のスコア
  int get leftScore => _leftScore;

  /// 右側選手のスコア
  int get rightScore => _rightScore;

  /// 文字列形式の残り時間
  String get remainingTime {
    var minutes = _secondsLeft ~/ 60;
    var seconds = _secondsLeft - minutes * 60;
    return "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
  }

  /// タイマーインスタンス
  Timer? timer;

  /// タイマー起動中か
  bool _isTimerStarting = false;

  /// タイマー起動中かゲッター
  bool get isTimerStarting => _isTimerStarting;

  /// タイマー起動中かセッター
  set isTimerStarting(bool isStarting) {
    _isTimerStarting = isStarting;
    notifyListeners();
  }

  /// 左側選手のスコア
  int _leftScore = 0;

  /// 右側選手のスコア
  int _rightScore = 0;

  /// 残り秒数
  int _secondsLeft = 180;

  int get secondsLeft => _secondsLeft;

  set secondsLeft(int seconds) {
    _secondsLeft = seconds;
    notifyListeners();
  }

  /// 最新のビデオファイルパス
  String? _latestVideoFilePath;

  String? get latestVideoFilePath => _latestVideoFilePath;

  set latestVideoFilePath(String? path) {
    _latestVideoFilePath = path;
    notifyListeners();
  }

  /// 残り秒数を1減らす
  void minusSeconds() {
    if (_secondsLeft > 0) {
      _secondsLeft--;
      notifyListeners();
    }
  }

  /// 左側選手のスコアを増やす
  void getLeftScoreUp() {
    _leftScore++;
    notifyListeners();
  }

  /// 左側選手のスコアを減らす
  void getLeftScoreDown() {
    _leftScore--;
    notifyListeners();
  }

  /// 右側選手のスコアを増やす
  void getRightScoreUp() {
    _rightScore++;
    notifyListeners();
  }

  /// 右側選手のスコアを減らす
  void getRightScoreDown() {
    _rightScore--;
    notifyListeners();
  }

  /// スコア・時間をリセットする
  void resetAll() {
    _leftScore = 0;
    _rightScore = 0;
    _secondsLeft = 180;
    notifyListeners();
  }
}
