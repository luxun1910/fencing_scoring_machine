import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: _videoPlayerController.value.aspectRatio, //アスペクト比
      autoPlay: false, //自動再生
      looping: true, //繰り返し再生

      // 以下はオプション（なくてもOK）
      showControls: true, //コントロールバーの表示（デフォルトではtrue）
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.red, //再生済み部分（左側）の色
        handleColor: Colors.blue, //再生地点を示すハンドルの色
        backgroundColor: Colors.grey, //再生前のプログレスバーの色
        bufferedColor: Colors.lightGreen, //未再生部分（右側）の色
      ),
      placeholder: Container(
        color: Colors.grey, //動画読み込み前の背景色
      ),
      autoInitialize: true, //widget呼び出し時に動画を読み込むかどうか
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((AppLocalizations.of(context)!.videoPageTitle)),
        actions: [
          GestureDetector(
            child: const Icon(Icons.save),
            onTap: () {
              // タップ時処理
              saveVideoToGallery(context, widget.videoPath);
            },
          ),
          const SizedBox(
            width: 10, // 位置調整
          )
        ],
      ),
      body: Chewie(
        controller: _chewieController,
      ),
    );
  }

  void saveVideoToGallery(BuildContext context, String videoFilePath) async {
    await GallerySaver.saveVideo(videoFilePath, albumName: 'fencing_video')
        .then((result) => {
              if (result!)
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
