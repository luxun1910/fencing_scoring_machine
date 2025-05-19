import 'package:fencing_scoring_machine/model/fencing_scoring_machine/fencing_scoring_machine_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  late FencingScoringMachineModel machine;

  setUp(() {
    machine = FencingScoringMachineModel();
  });

  group('FencingScoringMachine', () {
    test('初期残り時間表示は「03:00」である', () {
      expect(machine.remainingTime, "03:00");
    });

    test('残り時間が1減ると「02:59」と表示される', () {
      machine.minusSeconds();
      expect(machine.remainingTime, "02:59");
    });

    test('残り時間が0の状態でそれ以上減らない', () {
      // 秒数を0にする
      machine.secondsLeft = 0;
      expect(machine.remainingTime, "00:00");

      // さらに減らそうとしても変わらない
      machine.minusSeconds();
      expect(machine.remainingTime, "00:00");
    });

    test('左側の選手のスコアが1増える', () {
      machine.getLeftScoreUp();
      expect(machine.leftScore, 1);
    });

    test('右側の選手のスコアが1増える', () {
      machine.getRightScoreUp();
      expect(machine.rightScore, 1);
    });

    test('左側の選手のスコアが1減る', () {
      machine.getLeftScoreDown();
      expect(machine.leftScore, -1);
    });

    test('右側の選手のスコアが1減る', () {
      machine.getRightScoreDown();
      expect(machine.rightScore, -1);
    });

    test('リセットすると左右のスコアが0になり、残り時間が3分になること', () {
      machine.minusSeconds();
      machine.getLeftScoreUp();
      machine.getRightScoreUp();
      machine.resetAll();

      expect(machine.leftScore, 0);
      expect(machine.rightScore, 0);
      expect(machine.remainingTime, "03:00");
    });

    test('複数回スコアを増減させた場合に正しく計算されること', () {
      machine.getLeftScoreUp();
      machine.getLeftScoreUp();
      machine.getLeftScoreDown();
      expect(machine.leftScore, 1);

      machine.getRightScoreUp();
      machine.getRightScoreUp();
      machine.getRightScoreUp();
      machine.getRightScoreDown();
      expect(machine.rightScore, 2);
    });

    test('タイマーの初期状態は停止している', () {
      expect(machine.isTimerStarting, false);
    });

    test('タイマーの状態を変更できる', () {
      machine.isTimerStarting = true;
      expect(machine.isTimerStarting, true);

      machine.isTimerStarting = false;
      expect(machine.isTimerStarting, false);
    });

    test('残り時間を直接設定できる', () {
      machine.secondsLeft = 120;
      expect(machine.remainingTime, "02:00");

      machine.secondsLeft = 30;
      expect(machine.remainingTime, "00:30");
    });

    test('latestVideoFilePathの初期値はnullである', () {
      expect(machine.latestVideoFilePath, null);
    });

    test('latestVideoFilePathを設定・取得できる', () {
      const testPath = "/test/video/path.mp4";
      machine.latestVideoFilePath = testPath;
      expect(machine.latestVideoFilePath, testPath);

      machine.latestVideoFilePath = null;
      expect(machine.latestVideoFilePath, null);
    });
  });
}
