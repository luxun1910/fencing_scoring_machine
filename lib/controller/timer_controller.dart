import 'dart:async';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine.dart';
import 'package:flutter/material.dart';

class TimerController {
  final FencingScoringMachine _machine;

  TimerController(this._machine);

  void dispose() {
    stopTimer();
  }

  // タイマーを開始または停止する
  void toggleTimer() {
    if (!_machine.isTimerStarting) {
      startTimer();
    } else {
      stopTimer();
    }
  }

  // タイマーを開始する
  void startTimer() {
    _machine.isTimerStarting = true;
    _machine.timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        _machine.minusSeconds();
      },
    );
  }

  // タイマーを停止する
  void stopTimer() {
    _machine.isTimerStarting = false;
    _machine.timer?.cancel();
  }

  // 時間を設定する
  void setTime(int seconds) {
    stopTimer();
    _machine.secondsLeft = seconds;
  }

  // ダイアログを表示して時間を変更する
  void openChangeTimeDialog(BuildContext context) {
    if (_machine.isTimerStarting) {
      return;
    }

    final formKey = GlobalKey<FormState>();
    int? minutes;
    int? seconds;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('時間設定'),
          content: Form(
            key: formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: '分'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => minutes = int.tryParse(value ?? ''),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '分を入力してください';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: '秒'),
                    keyboardType: TextInputType.number,
                    onSaved: (value) => seconds = int.tryParse(value ?? ''),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '秒を入力してください';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final totalSeconds = (minutes ?? 0) * 60 + (seconds ?? 0);
                  setTime(totalSeconds);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('設定'),
            ),
          ],
        );
      },
    );
  }
}
