import 'package:fencing_scoring_machine/model/settings_model.dart';

/// 設定画面コントローラー
class SettingsController {
  final SettingsModel _settingsModel;

  SettingsController(this._settingsModel);

  /// ビデオ有効/無効の設定
  Future<void> setVideoEnable(bool value) async {
    await _settingsModel.setVideoEnable(value);
  }

  /// ビデオ自動保存の設定
  Future<void> setIsVideoAutoSave(bool value) async {
    await _settingsModel.setIsVideoAutoSave(value);
  }

  /// ビデオプレビューサイズの設定
  Future<void> setCameraPreviewSize(int size) async {
    await _settingsModel.setCameraPreviewSize(size);
  }

  /// ビデオプレビュー位置の設定
  Future<void> setVideoPreviewPositionWhenLandscape(Position position) async {
    await _settingsModel.setVideoPreviewPositionWhenLandscape(position);
  }

  /// ダブルボタン有効/無効の設定
  Future<void> setDoubleButtonEnable(bool value) async {
    await _settingsModel.setDoubleButtonEnable(value);
  }

  /// セット数カウント有効/無効の設定
  Future<void> setSetCountEnable(bool value) async {
    await _settingsModel.setSetCountEnable(value);
  }
}
