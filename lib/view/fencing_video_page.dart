import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:fencing_scoring_machine/model/video_player_model.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoPlayerModel(videoPath: videoPath),
      child: const _VideoPlayerScreenContent(),
    );
  }
}

class _VideoPlayerScreenContent extends StatelessWidget {
  const _VideoPlayerScreenContent();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<VideoPlayerModel>();

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
