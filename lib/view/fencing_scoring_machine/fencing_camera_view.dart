import 'package:camera/camera.dart';
import 'package:fencing_scoring_machine/controller/fencing_scoring_machine_controller.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine/fencing_camera_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// フェンシングカメラ画面
class FencingCameraView extends StatelessWidget {
  const FencingCameraView({super.key});

  @override
  Widget build(BuildContext context) {
    final camera = context.watch<FencingCameraModel>();
    return GestureDetector(
      onTap: () {
        if (!camera.cameraController.value.isRecordingVideo) {
          context
              .read<FencingScoringMachineController>()
              .moveToVideoPlayer(context);
        }
      },
      child: FutureBuilder<void>(
        future: camera.initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!
                        .offerPermissionDialogTitle),
                    content:
                        Text(AppLocalizations.of(context)!.offerPermissionText),
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
            });
            return Container();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  flex: 5,
                  child: AspectRatio(
                    aspectRatio: camera.cameraController.value.aspectRatio,
                    child: CameraPreview(camera.cameraController),
                  ),
                ),
                const Expanded(flex: 1, child: SizedBox(child: CameraSlider()))
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class CameraSlider extends StatelessWidget {
  const CameraSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FencingCameraModel>(
      builder: (context, camera, child) {
        return FutureBuilder<void>(
          future: camera.setZoomLevel(),
          builder: (context, snapshot) {
            if (camera.maxZoomLevel > 0 && camera.minZoomLevel > 0) {
              return Slider(
                activeColor: Colors.red,
                value: camera.sliderValue,
                min: camera.minZoomLevel / 10,
                max: camera.maxZoomLevel / 10,
                onChanged: (value) {
                  camera.updateSliderValue(value);
                },
              );
            } else {
              return Container();
            }
          },
        );
      },
    );
  }
}
