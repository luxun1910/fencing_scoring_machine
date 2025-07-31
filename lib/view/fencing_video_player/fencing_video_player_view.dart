import 'package:fencing_scoring_machine/controller/fencing_video_player_controller.dart';
import 'package:fencing_scoring_machine/model/fencing_video_player/fencing_video_player_model.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Fencing video player screen
class FencingVideoPlayerView extends StatelessWidget {
  const FencingVideoPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<FencingVideoPlayerController>();
    final model = context.watch<FencingVideoPlayerModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.videoPageTitle),
        actions: [
          GestureDetector(
            child: const Icon(Icons.save),
            onTap: () async {
              // Tap processing
              final result = await controller.saveVideoToGallery();
              if (result && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        AppLocalizations.of(context)!.videoSaveSuccessMessage),
                  ),
                );
              }
            },
          ),
          const SizedBox(
            width: 10, // Position adjustment
          )
        ],
      ),
      body: _buildBody(model),
    );
  }

  Widget _buildBody(FencingVideoPlayerModel model) {
    // Switch UI based on initialization status flag
    if (model.isChewieControllerInitialized) {
      return Chewie(
        controller: model.chewieController,
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
