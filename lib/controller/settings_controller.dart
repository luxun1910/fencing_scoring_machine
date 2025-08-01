import 'package:fencing_scoring_machine/model/settings/settings_page_model.dart';

/// Settings controller
class SettingsController {
  final SettingsPageModel _settingsModel;

  SettingsController(this._settingsModel);

  /// Video enable/disable setting
  Future<void> setVideoEnable(bool value) async {
    await _settingsModel.setVideoEnable(value);
  }

  /// Video auto save setting
  Future<void> setIsVideoAutoSave(bool value) async {
    await _settingsModel.setIsVideoAutoSave(value);
  }

  /// Video preview size setting
  Future<void> setCameraPreviewSize(int size) async {
    await _settingsModel.setCameraPreviewSize(size);
  }

  /// Video preview position setting
  Future<void> setVideoPreviewPositionWhenLandscape(Position position) async {
    await _settingsModel.setVideoPreviewPositionWhenLandscape(position);
  }

  /// Double button enable/disable setting
  Future<void> setDoubleButtonEnable(bool value) async {
    await _settingsModel.setDoubleButtonEnable(value);
  }

  /// Set match number count enable/disable setting
  Future<void> setMatchNumberCountEnable(bool value) async {
    await _settingsModel.setMatchNumberCountEnable(value);
  }
}
