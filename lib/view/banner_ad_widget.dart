import 'package:fencing_scoring_machine/model/banner_ad_widget_model.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

/// Banner ad widget
class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<BannerAdWidgetModel>().loadBannerAd();

    var bannerAd = context.watch<BannerAdWidgetModel>().bannerAd;
    return bannerAd == null
        ? const SizedBox()
        : SizedBox(
            width: bannerAd.size.width.toDouble(),
            height: bannerAd.size.height.toDouble(),
            child: AdWidget(
              ad: bannerAd,
            ),
          );
  }
}
