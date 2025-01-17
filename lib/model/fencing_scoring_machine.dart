import 'dart:async';
import 'package:flutter/material.dart';

// フェンシング審判機モデル
class FencingScoringMachine extends ChangeNotifier with WidgetsBindingObserver {
  FencingScoringMachine() {
    WidgetsBinding.instance.addObserver(this);
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 左側選手のスコア
  int get leftScore => _leftScore;

  // 右側選手のスコア
  int get rightScore => _rightScore;

  // 文字列形式の残り時間
  String get remainingTime {
    var minutes = _secondsLeft ~/ 60;
    var seconds = _secondsLeft - minutes * 60;
    return "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
  }

  // タイマーインスタンス
  Timer? timer;

  // タイマー起動中か
  bool _isTimerStarting = false;

  bool get isTimerStarting => _isTimerStarting;

  set isTimerStarting(bool isStarting) {
    _isTimerStarting = isStarting;
    notifyListeners();
  }

  // 左側選手のスコア
  int _leftScore = 0;

  // 右側選手のスコア
  int _rightScore = 0;

  // 残り秒数
  int _secondsLeft = 180;

  int get secondsLeft => _secondsLeft;

  set secondsLeft(int seconds) {
    _secondsLeft = seconds;
    notifyListeners();
  }

  // 最新のビデオパス
  String? _latestVideoPath;

  String? get latestVideoPath => _latestVideoPath;

  set latestVideoPath(String? path) {
    _latestVideoPath = path;
    notifyListeners();
  }

  // 残り秒数を1減らす
  void minusSeconds() {
    if (_secondsLeft > 0) {
      _secondsLeft--;
      notifyListeners();
    }
  }

  // 左側選手のスコアを増やす
  void getLeftScoreUp() {
    _leftScore++;
    notifyListeners();
  }

  // 左側選手のスコアを減らす
  void getLeftScoreDown() {
    _leftScore--;
    notifyListeners();
  }

  // 右側選手のスコアを増やす
  void getRightScoreUp() {
    _rightScore++;
    notifyListeners();
  }

  // 右側選手のスコアを減らす
  void getRightScoreDown() {
    _rightScore--;
    notifyListeners();
  }

  // スコア・時間をリセットする
  void resetAll() {
    _leftScore = 0;
    _rightScore = 0;
    _secondsLeft = 180;
    notifyListeners();
  }
}
