import 'dart:io';

import 'package:fencing_scoring_machine/log_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdModel extends ChangeNotifier with WidgetsBindingObserver {
  BannerAdModel() {
    bannerAd = BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.fullBanner,
        request: const AdRequest(),
        listener: const BannerAdListener());
    logger.i("広告初期化完了");
    WidgetsBinding.instance.addObserver(this);
    notifyListeners();
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    super.dispose();
  }

  BannerAd? bannerAd;

  String get bannerAdUnitId {
    var bunnerAdUnitIDForAndroid =
        const String.fromEnvironment('bunnerAdUnitIDForAndroid');

    if (Platform.isAndroid) {
      // 広告
      return bunnerAdUnitIDForAndroid;
    } else if (Platform.isIOS) {
      //テスト広告
      return "ca-app-pub-3940256099942544/2934735716";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  void loadBannerAd() async {
    await bannerAd?.load();
    logger.i("広告読み込み完了");
  }
}
