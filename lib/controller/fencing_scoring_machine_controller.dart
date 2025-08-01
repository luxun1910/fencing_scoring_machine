import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:fencing_scoring_machine/app_constants.dart';
import 'package:fencing_scoring_machine/log_helper.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine/fencing_camera_widget_model.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine/fencing_scoring_machine_page_model.dart';
import 'package:fencing_scoring_machine/model/fencing_video_player/fencing_video_player_page_model.dart';
import 'package:fencing_scoring_machine/model/settings/settings_page_model.dart';
import 'package:fencing_scoring_machine/view/fencing_video_player/fencing_video_player_page.dart';
import 'package:fencing_scoring_machine/view/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Fencing scoring machine controller
class FencingScoringMachineController extends WidgetsBindingObserver {
  FencingScoringMachineController(
      FencingScoringMachinePageModel machine,
      FencingCameraWidgetModel cameraModel,
      SettingsPageModel settings,
      FencingVideoPlayerPageModel videoPlayerModel) {
    _machine = machine;
    _settings = settings;
    _cameraModel = cameraModel;
    _videoPlayerModel = videoPlayerModel;

    WidgetsBinding.instance.addObserver(this);
  }

  /// Fencing scoring machine model
  late FencingScoringMachinePageModel _machine;

  /// Settings model
  late SettingsPageModel _settings;

  /// Fencing camera model
  late FencingCameraWidgetModel _cameraModel;

  /// Fencing video player model
  late FencingVideoPlayerPageModel _videoPlayerModel;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _stopTimer();
    }
  }

  /// Press timer button
  void pushTimer() async {
    if (!_machine.isTimerStarting) {
      // Timer start
      _machine.isTimerStarting = true;
      _machine.timer = Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) {
          _machine.minusSeconds();
        },
      );
    } else {
      _stopTimer();
    }

    // Video recording related
    if (_settings.isVideoEnable) {
      try {
        // Exit if camera is not initialized
        if (!_cameraModel.cameraController.value.isInitialized) {
          logger.e("Camera is not initialized.");
          return;
        }
        // Stop recording if camera recording has already started
        if (_cameraModel.cameraController.value.isRecordingVideo) {
          _stopRecording();
          return;
        }
        try {
          await _cameraModel.cameraController.prepareForVideoRecording();
          await _cameraModel.cameraController.startVideoRecording();
          logger.d("Video recording started");
        } on CameraException catch (e) {
          logger.e("Video recording failed", error: e);
        }
      } catch (e) {
        logger.e(e.toString(), error: e);
      }
    }
  }

  /// Stop timer
  void _stopTimer() {
    _machine.isTimerStarting = false;
    _machine.timer?.cancel();
  }

  /// Stop video recording
  void _stopRecording() async {
    if (_settings.isVideoEnable) {
      logger.d("Video recording stopped");
      // Stop camera and save
      var video = await _cameraModel.cameraController.stopVideoRecording();
      _setCurrentLatestVideoFilePath(video.path);
    }
  }

  /// Increase left player's score by 1
  void leftScoreUp() {
    _stopTimer();
    _machine.getLeftScoreUp();
    if (_cameraModel.cameraController.value.isRecordingVideo) {
      _stopRecording();
    }
  }

  /// Decrease left player's score by 1
  void leftScoreDown() {
    _stopTimer();
    _machine.getLeftScoreDown();
    if (_cameraModel.cameraController.value.isRecordingVideo) {
      _stopRecording();
    }
  }

  /// Increase right player's score by 1
  void rightScoreUp() {
    _stopTimer();
    _machine.getRightScoreUp();
    if (_cameraModel.cameraController.value.isRecordingVideo) {
      _stopRecording();
    }
  }

  /// Decrease right player's score by 1
  void rightScoreDown() {
    _stopTimer();
    _machine.getRightScoreDown();
    if (_cameraModel.cameraController.value.isRecordingVideo) {
      _stopRecording();
    }
  }

  void doubleHit() {
    _stopTimer();
    _machine.getLeftScoreUp();
    _machine.getRightScoreUp();
    if (_cameraModel.cameraController.value.isRecordingVideo) {
      _stopRecording();
    }
  }

  /// Reset all scores and remaining time to 3 minutes
  void resetAll() {
    _stopTimer();
    _machine.resetAll();
    if (_cameraModel.cameraController.value.isRecordingVideo) {
      _stopRecording();
    }
  }

  /// Increase match number
  void increaseMatchNumber() {
    _machine.increaseMatchNumber();
  }

  /// Decrease match number
  void decreaseMatchNumber() {
    _machine.decreaseMatchNumber();
  }

  /// Save the latest video file path
  void _setCurrentLatestVideoFilePath(String xfileVideoPath) {
    if (_settings.isVideoAutoSave) {
      GallerySaver.saveVideo(xfileVideoPath, albumName: AppConstants.albumName);
    }

    /// Delete all existing videos
    var xfileVideoDir = File(xfileVideoPath).parent;
    xfileVideoDir
        .listSync()
        .where((element) => element.path.endsWith('.mp4'))
        .forEach((fileEntity) {
      if (fileEntity.path != xfileVideoPath) {
        fileEntity.deleteSync();
      }
    });

    // Save the latest video path
    _machine.latestVideoFilePath = xfileVideoPath;
  }

  /// Move to video player screen
  void moveToVideoPlayer(BuildContext context) {
    if (_machine.latestVideoFilePath != null &&
        _machine.latestVideoFilePath!.isNotEmpty) {
      _videoPlayerModel.videoFilePath = _machine.latestVideoFilePath!;
      _videoPlayerModel.initControllers();
      Navigator.of(context)
          .push(MaterialPageRoute(
        builder: (context) => const FencingVideoPlayerPage(),
      ))
          .then((_) {
        _videoPlayerModel.chewieController.dispose();
        _videoPlayerModel.videoPlayerController.dispose();
      });
    }
  }

  /// Move to settings screen
  void moveToSettingsPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const SettingsPage(),
    ));
  }

  /// Open timer setting dialog
  void openChangeTimeDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    var minutes = _machine.secondsLeft ~/ 60;
    var seconds = _machine.secondsLeft - minutes * 60;

    int dropdownValue1 = minutes;
    int dropdownValue2 = seconds;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.timerSettingTitle),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      child: DropdownButtonFormField<int>(
                        value: dropdownValue1,
                        hint: Text(
                            AppLocalizations.of(context)!.selectNumberHint),
                        items: List<int>.generate(4, (i) => i).map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          dropdownValue1 = (newValue) as int;
                        },
                        validator: (value) {
                          if (value == null) {
                            return AppLocalizations.of(context)!.selectNumber;
                          }
                          return null;
                        },
                      ),
                    ),
                    Flexible(
                      child: DropdownButtonFormField<int>(
                        value: dropdownValue2,
                        hint: Text(
                            AppLocalizations.of(context)!.selectNumberHint),
                        items:
                            List<int>.generate(60, (i) => i).map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString().padLeft(2, '0')),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          dropdownValue2 = (newValue) as int;
                        },
                        validator: (value) {
                          if (value == null) {
                            return AppLocalizations.of(context)!.selectNumber;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      _machine.secondsLeft =
                          dropdownValue1 * 60 + dropdownValue2;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(AppLocalizations.of(context)!
                                .matchNumberChangedMessage)),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.change),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Open match number setting dialog
  void openChangeMatchNumberDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    var matchNumberOnDialog = _machine.matchNumber;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.matchNumberSettingTitle),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      child: DropdownButtonFormField<int>(
                        value: matchNumberOnDialog,
                        hint: Text(
                            AppLocalizations.of(context)!.selectNumberHint),
                        items: List<int>.generate(9, (i) => i + 1)
                            .map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          matchNumberOnDialog = (newValue) as int;
                        },
                        validator: (value) {
                          if (value == null) {
                            return AppLocalizations.of(context)!.selectNumber;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      _machine.matchNumber = matchNumberOnDialog;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(AppLocalizations.of(context)!
                                .matchNumberChangedMessage)),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.change),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
