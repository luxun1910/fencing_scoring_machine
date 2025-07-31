import 'dart:io';

import 'package:fencing_scoring_machine/log_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Banner ad model
class BannerAdModel extends ChangeNotifier with WidgetsBindingObserver {
  BannerAdModel() {
    bannerAd = BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.fullBanner,
        request: const AdRequest(),
        listener: const BannerAdListener());
    logger.i("Banner ad initialized");
    WidgetsBinding.instance.addObserver(this);
    notifyListeners();
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    super.dispose();
  }

  /// Banner ad
  BannerAd? bannerAd;

  /// Banner ad ID
  String get bannerAdUnitId {
    var bunnerAdUnitIDForAndroid =
        const String.fromEnvironment('bunnerAdUnitIDForAndroid');

    if (Platform.isAndroid) {
      // Advertisement
      return bunnerAdUnitIDForAndroid;
    } else if (Platform.isIOS) {
      // Test advertisement
      return "ca-app-pub-3940256099942544/2934735716";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  /// Load banner ad
  void loadBannerAd() async {
    await bannerAd?.load();
    logger.i("Banner ad loaded");
  }
}
