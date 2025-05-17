import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../controller/video_page_controller.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  Widget build(BuildContext context) {
    return _VideoProviderWidget(
      videoPath: videoPath,
      child: _VideoPlayerContent(videoPath: videoPath),
    );
  }
}

class _VideoProviderWidget extends StatefulWidget {
  final Widget child;
  final String videoPath;

  const _VideoProviderWidget({
    required this.child,
    required this.videoPath,
  });

  @override
  State<_VideoProviderWidget> createState() => _VideoProviderWidgetState();
}

class _VideoProviderWidgetState extends State<_VideoProviderWidget> {
  late final VideoPageController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPageController();
    controller.initializePlayer(widget.videoPath);
  }

  @override
  void dispose() {
    controller.disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: widget.child,
    );
  }
}

class _VideoPlayerContent extends StatelessWidget {
  final String videoPath;

  const _VideoPlayerContent({required this.videoPath});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<VideoPageController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text((AppLocalizations.of(context)!.videoPageTitle)),
        actions: [
          GestureDetector(
            child: const Icon(Icons.save),
            onTap: () {
              // タップ時処理
              saveVideoToGallery(context, videoPath);
            },
          ),
          const SizedBox(
            width: 10, // 位置調整
          )
        ],
      ),
      body: controller.isInitialized && controller.chewieController != null
          ? Chewie(
              controller: controller.chewieController!,
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void saveVideoToGallery(BuildContext context, String videoFilePath) async {
    await GallerySaver.saveVideo(videoFilePath, albumName: 'fencing_video')
        .then((result) => {
              if (result! && true)
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!
                          .videoSaveSuccessMessage),
                    ),
                  )
                }
            });
  }
}
