import 'package:fencing_scoring_machine/model/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
      ),
      body: SingleChildScrollView(
        child: Consumer<Settings>(
          builder: (context, settings, child) {
            return Column(
              children: <Widget>[
                ListTile(
                  title:
                      Text(AppLocalizations.of(context)!.videoEnableOptionText),
                ),
                ListBody(
                  children: [
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.enable),
                      leading: Radio<bool>(
                        value: true,
                        groupValue: settings.isVideoEnable,
                        onChanged: (value) {
                          settings.setVideoEnable(value!);
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.disable),
                      leading: Radio<bool>(
                        value: false,
                        groupValue: settings.isVideoEnable,
                        onChanged: (value) {
                          settings.setVideoEnable(value!);
                        },
                      ),
                    ),
                  ],
                ),
                ListTile(
                  title: Text(
                      AppLocalizations.of(context)!.videoAutosaveOptionText),
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
                          settings.setIsVideoAutoSave(value!);
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.disable),
                      leading: Radio<bool>(
                        value: false,
                        groupValue: settings.isVideoAutoSave,
                        onChanged: (value) {
                          settings.setIsVideoAutoSave(value!);
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
                          settings.setCameraPreviewSize(value!);
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('M'),
                      leading: Radio<int>(
                        value: 2,
                        groupValue: settings.videoPreviewSize,
                        onChanged: (value) {
                          settings.setCameraPreviewSize(value!);
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('L'),
                      leading: Radio<int>(
                        value: 3,
                        groupValue: settings.videoPreviewSize,
                        onChanged: (value) {
                          settings.setCameraPreviewSize(value!);
                        },
                      ),
                    ),
                  ],
                ),
                ListTile(
                  title: Text(
                      AppLocalizations.of(context)!.videoPositionOptionText),
                ),
                ListBody(
                  children: [
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.left),
                      leading: Radio<Position>(
                        value: Position.left,
                        groupValue: settings.videoPreviewPositionWhenLandscape,
                        onChanged: (value) {
                          settings.setVideoPreviewPositionWhenLandscape(value!);
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.right),
                      leading: Radio<Position>(
                        value: Position.right,
                        groupValue: settings.videoPreviewPositionWhenLandscape,
                        onChanged: (value) {
                          settings.setVideoPreviewPositionWhenLandscape(value!);
                        },
                      ),
                    ),
                  ],
                ),
                ListTile(
                  title: Text(
                      AppLocalizations.of(context)!.doubleButtonOptionText),
                ),
                ListBody(
                  children: [
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.enable),
                      leading: Radio<bool>(
                        value: true,
                        groupValue: settings.isDoubleButtonEnable,
                        onChanged: (value) {
                          settings.setDoubleButtonEnable(value!);
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(AppLocalizations.of(context)!.disable),
                      leading: Radio<bool>(
                        value: false,
                        groupValue: settings.isDoubleButtonEnable,
                        onChanged: (value) {
                          settings.setDoubleButtonEnable(value!);
                        },
                      ),
                    ),
                  ],
                ),
                ListTile(
                  title: Text(
                      AppLocalizations.of(context)!.privacyPolicy,
                      style: const TextStyle(color: Colors.blue),),
                  onTap: () => {launchUrl(Uri.parse("https://luxun1910.github.io/unanimousworks_privacy_policy/fencing_scoring_machine.html"))},
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
