import 'package:fencing_scoring_machine/model/banner_ad_model.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

/// Banner ad display screen
class BannerAdView extends StatelessWidget {
  const BannerAdView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<BannerAdModel>().loadBannerAd();

    var bannerAd = context.watch<BannerAdModel>().bannerAd;
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
