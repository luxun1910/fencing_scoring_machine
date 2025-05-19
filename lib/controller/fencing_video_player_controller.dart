import 'package:fencing_scoring_machine/model/fencing_video_player/fencing_video_player_model.dart';

class FencingVideoPlayerController {
  late FencingVideoPlayerModel _model;

  FencingVideoPlayerController(FencingVideoPlayerModel model) {
    _model = model;
  }

  Future<bool> saveVideoToGallery() async {
    final result = await _model.saveVideoToGallery();
    return result;
  }
}
