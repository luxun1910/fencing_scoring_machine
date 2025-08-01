import 'package:fencing_scoring_machine/controller/settings_controller.dart';
import 'package:fencing_scoring_machine/model/settings/settings_page_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings screen
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsPageModel>();
    final controller = context.read<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(AppLocalizations.of(context)!.videoEnableOptionText),
            ),
            ListBody(
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context)!.enable),
                  leading: Radio<bool>(
                    value: true,
                    groupValue: settings.isVideoEnable,
                    onChanged: (value) {
                      controller.setVideoEnable(value!);
                    },
                  ),
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context)!.disable),
                  leading: Radio<bool>(
                    value: false,
                    groupValue: settings.isVideoEnable,
                    onChanged: (value) {
                      controller.setVideoEnable(value!);
                    },
                  ),
                ),
              ],
            ),
            ListTile(
              title:
                  Text(AppLocalizations.of(context)!.videoAutosaveOptionText),
              subtitle: Text(
                  AppLocalizations.of(context)!.videoAutosaveOptionSubText),
            ),
            ListBody(
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context)!.enable),
                  leading: Radio<bool>(
                    value: true,
                    groupValue: settings.isVideoAutoSave,
                    onChanged: (value) {
                      controller.setIsVideoAutoSave(value!);
                    },
                  ),
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context)!.disable),
                  leading: Radio<bool>(
                    value: false,
                    groupValue: settings.isVideoAutoSave,
                    onChanged: (value) {
                      controller.setIsVideoAutoSave(value!);
                    },
                  ),
                ),
              ],
            ),
            ListTile(
              title: Text(
                  AppLocalizations.of(context)!.videoPreviewSizeOptionText),
            ),
            ListBody(
              children: [
                ListTile(
                  title: const Text('S'),
                  leading: Radio<int>(
                    value: 1,
                    groupValue: settings.videoPreviewSize,
                    onChanged: (value) {
                      controller.setCameraPreviewSize(value!);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('M'),
                  leading: Radio<int>(
                    value: 2,
                    groupValue: settings.videoPreviewSize,
                    onChanged: (value) {
                      controller.setCameraPreviewSize(value!);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('L'),
                  leading: Radio<int>(
                    value: 3,
                    groupValue: settings.videoPreviewSize,
                    onChanged: (value) {
                      controller.setCameraPreviewSize(value!);
                    },
                  ),
                ),
              ],
            ),
            ListTile(
              title:
                  Text(AppLocalizations.of(context)!.videoPositionOptionText),
            ),
            ListBody(
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context)!.left),
                  leading: Radio<Position>(
                    value: Position.left,
                    groupValue: settings.videoPreviewPositionWhenLandscape,
                    onChanged: (value) {
                      controller.setVideoPreviewPositionWhenLandscape(value!);
                    },
                  ),
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context)!.right),
                  leading: Radio<Position>(
                    value: Position.right,
                    groupValue: settings.videoPreviewPositionWhenLandscape,
                    onChanged: (value) {
                      controller.setVideoPreviewPositionWhenLandscape(value!);
                    },
                  ),
                ),
              ],
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.doubleButtonOptionText),
            ),
            ListBody(
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context)!.enable),
                  leading: Radio<bool>(
                    value: true,
                    groupValue: settings.isDoubleButtonEnable,
                    onChanged: (value) {
                      controller.setDoubleButtonEnable(value!);
                    },
                  ),
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context)!.disable),
                  leading: Radio<bool>(
                    value: false,
                    groupValue: settings.isDoubleButtonEnable,
                    onChanged: (value) {
                      controller.setDoubleButtonEnable(value!);
                    },
                  ),
                ),
              ],
            ),
            ListTile(
              title: Text(
                  AppLocalizations.of(context)!.matchNumberCountOptionText),
            ),
            ListBody(
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context)!.enable),
                  leading: Radio<bool>(
                    value: true,
                    groupValue: settings.isMatchNumberCountEnable,
                    onChanged: (value) {
                      controller.setMatchNumberCountEnable(value!);
                    },
                  ),
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context)!.disable),
                  leading: Radio<bool>(
                    value: false,
                    groupValue: settings.isMatchNumberCountEnable,
                    onChanged: (value) {
                      controller.setMatchNumberCountEnable(value!);
                    },
                  ),
                ),
              ],
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.privacyPolicy,
                style: const TextStyle(color: Colors.blue),
              ),
              onTap: () => {
                launchUrl(Uri.parse(
                    "https://luxun1910.github.io/unanimousworks_privacy_policy/fencing_scoring_machine.html"))
              },
            ),
          ],
        ),
      ),
    );
  }
}
