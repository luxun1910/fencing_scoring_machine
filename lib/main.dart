import 'package:camera/camera.dart';
import 'package:fencing_scoring_machine/controller/fencing_scoring_machine_controller.dart';
import 'package:fencing_scoring_machine/controller/fencing_video_player_controller.dart';
import 'package:fencing_scoring_machine/controller/settings_controller.dart';
import 'package:fencing_scoring_machine/model/banner_ad_widget_model.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine/fencing_camera_widget_model.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine/fencing_scoring_machine_page_model.dart';
import 'package:fencing_scoring_machine/model/fencing_video_player/fencing_video_player_page_model.dart';
import 'package:fencing_scoring_machine/model/settings/settings_page_model.dart';
import 'package:fencing_scoring_machine/view/fencing_scoring_machine/fencing_scoring_machine_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  MobileAds.instance.initialize();

  final firstCamera = cameras.first;

  runApp(MyApp(
    camera: firstCamera,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.camera});

  final CameraDescription camera;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FencingScoringMachinePageModel>(
            create: (_) => FencingScoringMachinePageModel()),
        ChangeNotifierProvider<FencingCameraWidgetModel>(
            create: (_) => FencingCameraWidgetModel(camera)),
        ChangeNotifierProvider<BannerAdWidgetModel>(
            create: (_) => BannerAdWidgetModel()),
        ChangeNotifierProvider<SettingsPageModel>(
            create: (_) => SettingsPageModel()),
        ProxyProvider<SettingsPageModel, SettingsController>(
          update: (_, settingsModel, __) => SettingsController(settingsModel),
        ),
        ChangeNotifierProvider<FencingVideoPlayerPageModel>(
            create: (_) => FencingVideoPlayerPageModel()),
        ProxyProvider<FencingVideoPlayerPageModel,
            FencingVideoPlayerController>(
          update: (_, videoPlayerModel, __) =>
              FencingVideoPlayerController(videoPlayerModel),
        ),
        ProxyProvider4<
            FencingScoringMachinePageModel,
            SettingsPageModel,
            FencingCameraWidgetModel,
            FencingVideoPlayerPageModel,
            FencingScoringMachineController>(
          update: (_, fencingScoringMachine, settings, cameraModel,
                  videoPlayerModel, __) =>
              FencingScoringMachineController(fencingScoringMachine,
                  cameraModel, settings, videoPlayerModel),
        ),
      ],
      child: MaterialApp(
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1)),
            child: child!,
          );
        },
        title: 'Fencing Scoring Machine',
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('ja'), // Japanese
          Locale('fr'), // French
        ],
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: const FencingScoringMachinePage(),
      ),
    );
  }
}
