import 'package:firebase_admob/firebase_admob.dart';
import 'package:instantonnection/application/AppConfig.dart';
import 'package:instantonnection/domain/repository/AdsRepository.dart';

class AdMobDataSource implements AdsRepository {
  final AppConfig _appConfig;

  AdMobDataSource(this._appConfig) {
    FirebaseAdMob.instance.initialize(appId: _appConfig.adMobIds.appId);
  }

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;

  @override
  Future<bool> dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    return Future.value(true);
  }

  BannerAd _createBannerAd() => BannerAd(
        adUnitId: _appConfig.adMobIds.bannerUnitId,
        size: AdSize.mediumRectangle,
        listener: (MobileAdEvent event) {},
      );

  InterstitialAd _createInterstitialAd() => InterstitialAd(
        adUnitId: _appConfig.adMobIds.interstitialUnitId,
        listener: (MobileAdEvent event) {},
      );

  @override
  Future<bool> showBanner() {
    _bannerAd ??= _createBannerAd();
    BannerAd ad = _bannerAd..load();
    return ad.show();
  }

  @override
  Future<bool> removeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    return Future.value(true);
  }

  @override
  Future<bool> loadInterstitial() {
    _interstitialAd?.dispose();
    _interstitialAd = _createInterstitialAd()..load();
    return Future.value(true);
  }

  @override
  Future<bool> showInterstitial() {
    return _interstitialAd.isLoaded().then((loaded) {
      if (loaded) {
        _interstitialAd?.show();
        return true;
      }
      return false;
    });
  }
}
