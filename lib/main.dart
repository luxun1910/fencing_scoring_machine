import 'package:camera/camera.dart';
import 'package:fencing_scoring_machine/controller/fencing_scoring_machine_controller.dart';
import 'package:fencing_scoring_machine/model/banner_ad_model.dart';
import 'package:fencing_scoring_machine/model/camera_model.dart';
import 'package:fencing_scoring_machine/model/fencing_scoring_machine.dart';
import 'package:fencing_scoring_machine/model/settings.dart';
import 'package:fencing_scoring_machine/view/fencing_scoring_machine_page.dart';
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
        ChangeNotifierProvider<FencingScoringMachine>(
            create: (_) => FencingScoringMachine()),
        ChangeNotifierProvider<CameraModel>(create: (_) => CameraModel(camera)),
        ChangeNotifierProvider<BannerAdModel>(create: (_) => BannerAdModel()),
        ChangeNotifierProvider<Settings>(create: (_) => Settings()),
        ProxyProvider3<FencingScoringMachine, Settings, CameraModel,
            FencingScoringMachineController>(
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
        home: const FencingScoringMachinePage(),
      ),
    );
  }
}
