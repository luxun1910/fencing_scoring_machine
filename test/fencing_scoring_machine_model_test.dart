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
    test('Initial remaining time display is "03:00"', () {
      expect(machine.remainingTime, "03:00");
    });

    test('When remaining time decreases by 1, it displays "02:59"', () {
      machine.minusSeconds();
      expect(machine.remainingTime, "02:59");
    });

    test('When remaining time is 0, it cannot be reduced further', () {
      // Set seconds to 0
      machine.secondsLeft = 0;
      expect(machine.remainingTime, "00:00");

      // Even if we try to reduce it further, it doesn't change
      machine.minusSeconds();
      expect(machine.remainingTime, "00:00");
    });

    test('Left player score increases by 1', () {
      machine.getLeftScoreUp();
      expect(machine.leftScore, 1);
    });

    test('Right player score increases by 1', () {
      machine.getRightScoreUp();
      expect(machine.rightScore, 1);
    });

    test('Left player score decreases by 1', () {
      machine.getLeftScoreDown();
      expect(machine.leftScore, -1);
    });

    test('Right player score decreases by 1', () {
      machine.getRightScoreDown();
      expect(machine.rightScore, -1);
    });

    test(
        'When reset, both left and right scores become 0 and remaining time becomes 3 minutes',
        () {
      machine.minusSeconds();
      machine.getLeftScoreUp();
      machine.getRightScoreUp();
      machine.resetAll();

      expect(machine.leftScore, 0);
      expect(machine.rightScore, 0);
      expect(machine.remainingTime, "03:00");
    });

    test(
        'When scores are increased and decreased multiple times, they are calculated correctly',
        () {
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

    test('Timer initial state is stopped', () {
      expect(machine.isTimerStarting, false);
    });

    test('Timer state can be changed', () {
      machine.isTimerStarting = true;
      expect(machine.isTimerStarting, true);

      machine.isTimerStarting = false;
      expect(machine.isTimerStarting, false);
    });

    test('Remaining time can be set directly', () {
      machine.secondsLeft = 120;
      expect(machine.remainingTime, "02:00");

      machine.secondsLeft = 30;
      expect(machine.remainingTime, "00:30");
    });

    test('Initial value of latestVideoFilePath is null', () {
      expect(machine.latestVideoFilePath, null);
    });

    test('latestVideoFilePath can be set and retrieved', () {
      const testPath = "/test/video/path.mp4";
      machine.latestVideoFilePath = testPath;
      expect(machine.latestVideoFilePath, testPath);

      machine.latestVideoFilePath = null;
      expect(machine.latestVideoFilePath, null);
    });
  });
}
