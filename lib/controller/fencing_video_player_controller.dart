import 'package:fencing_scoring_machine/model/fencing_video_player/fencing_video_player_page_model.dart';

/// Fencing video player controller
class FencingVideoPlayerController {
  late FencingVideoPlayerPageModel _model;

  FencingVideoPlayerController(FencingVideoPlayerPageModel model) {
    _model = model;
  }

  Future<bool> saveVideoToGallery() async {
    final result = await _model.saveVideoToGallery();
    return result;
  }
}
