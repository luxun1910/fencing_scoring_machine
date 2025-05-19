import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:fencing_scoring_machine/model/fencing_video_player/fencing_video_player_model.dart';

class FencingVideoPlayerView extends StatelessWidget {
  final String videoFilePath;

  const FencingVideoPlayerView({super.key, required this.videoFilePath});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FencingVideoPlayerModel(videoFilePath: videoFilePath),
      child: const _FencingVideoPlayerViewContent(),
    );
  }
}

class _FencingVideoPlayerViewContent extends StatelessWidget {
  const _FencingVideoPlayerViewContent();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<FencingVideoPlayerModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.videoPageTitle),
        actions: [
          GestureDetector(
            child: const Icon(Icons.save),
            onTap: () async {
              // タップ時処理
              final result = await model.saveVideoToGallery();
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
            width: 10, // 位置調整
          )
        ],
      ),
      body: Chewie(
        controller: model.chewieController,
      ),
    );
  }
}
