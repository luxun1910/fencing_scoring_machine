import 'dart:async';
import 'package:flutter/material.dart';

/// Fencing scoring machine page model
class FencingScoringMachinePageModel extends ChangeNotifier
    with WidgetsBindingObserver {
  FencingScoringMachinePageModel() {
    WidgetsBinding.instance.addObserver(this);
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Left player's score
  int get leftScore => _leftScore;

  /// Right player's score
  int get rightScore => _rightScore;

  /// Remaining time in string format
  String get remainingTime {
    var minutes = _secondsLeft ~/ 60;
    var seconds = _secondsLeft - minutes * 60;
    return "${minutes.toString().padLeft(2, "0")}:${seconds.toString().padLeft(2, "0")}";
  }

  /// Timer instance
  Timer? timer;

  /// Whether timer is running
  bool _isTimerStarting = false;

  /// Timer running status getter
  bool get isTimerStarting => _isTimerStarting;

  /// Timer running status setter
  set isTimerStarting(bool isStarting) {
    _isTimerStarting = isStarting;
    notifyListeners();
  }

  /// Left player's score
  int _leftScore = 0;

  /// Right player's score
  int _rightScore = 0;

  /// Remaining seconds
  int _secondsLeft = 180;

  int get secondsLeft => _secondsLeft;

  set secondsLeft(int seconds) {
    _secondsLeft = seconds;
    notifyListeners();
  }

  /// Match number
  int _matchNumber = 1;

  /// Get match number
  int get matchNumber => _matchNumber;

  /// Set match number value
  set matchNumber(int newMatchNumber) {
    if (newMatchNumber < 1) {
      newMatchNumber = 1;
    }
    if (newMatchNumber > 9) {
      newMatchNumber = 9;
    }
    _matchNumber = newMatchNumber;
    notifyListeners();
  }

  /// Increase match number
  void increaseMatchNumber() {
    if (_matchNumber < 9) {
      _matchNumber++;
    }
    notifyListeners();
  }

  /// Decrease match number
  void decreaseMatchNumber() {
    if (_matchNumber > 1) {
      _matchNumber--;
    }
    notifyListeners();
  }

  /// Latest video file path
  String? _latestVideoFilePath;

  String? get latestVideoFilePath => _latestVideoFilePath;

  set latestVideoFilePath(String? path) {
    _latestVideoFilePath = path;
    notifyListeners();
  }

  /// Decrease remaining seconds by 1
  void minusSeconds() {
    if (_secondsLeft > 0) {
      _secondsLeft--;
      notifyListeners();
    }
  }

  /// Increase left player's score
  void getLeftScoreUp() {
    _leftScore++;
    notifyListeners();
  }

  /// Decrease left player's score
  void getLeftScoreDown() {
    _leftScore--;
    notifyListeners();
  }

  /// Increase right player's score
  void getRightScoreUp() {
    _rightScore++;
    notifyListeners();
  }

  /// Decrease right player's score
  void getRightScoreDown() {
    _rightScore--;
    notifyListeners();
  }

  /// Reset scores and time
  void resetAll() {
    _leftScore = 0;
    _rightScore = 0;
    _secondsLeft = 180;
    notifyListeners();
  }
}
