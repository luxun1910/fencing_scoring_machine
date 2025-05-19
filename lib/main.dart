import 'package:camera/camera.dart';
import 'package:fencing_scoring_machine/controller/fencing_scoring_machine_controller.dart';
import 'package:fencing_scoring_machine/controller/settings_controller.dart';
import 'package:fencing_scoring_machine/model/banner_ad_model.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine/fencing_camera_model.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine/fencing_scoring_machine_model.dart';
import 'package:fencing_scoring_machine/model/settings_model.dart';
import 'package:fencing_scoring_machine/view/fencing_scoring_machine/fencing_scoring_machine_view.dart';
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
        ChangeNotifierProvider<FencingScoringMachineModel>(
            create: (_) => FencingScoringMachineModel()),
        ChangeNotifierProvider<FencingCameraModel>(
            create: (_) => FencingCameraModel(camera)),
        ChangeNotifierProvider<BannerAdModel>(create: (_) => BannerAdModel()),
        ChangeNotifierProvider<SettingsModel>(create: (_) => SettingsModel()),
        ProxyProvider<SettingsModel, SettingsController>(
          update: (_, settingsModel, __) => SettingsController(settingsModel),
        ),
        ProxyProvider3<FencingScoringMachineModel, SettingsModel,
            FencingCameraModel, FencingScoringMachineController>(
          update: (_, fencingScoringMachine, settings, cameraModel, __) =>
              FencingScoringMachineController(
                  fencingScoringMachine, cameraModel, settings),
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
          Locale('fr')
        ],
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: const FencingScoringMachineView(),
      ),
    );
  }
}
