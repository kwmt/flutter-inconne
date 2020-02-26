import 'dart:math';

import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/repository/AdsRepository.dart';

/// 広告ユースケース
abstract class AdsUseCase {
  Future<bool> dispose();

  // バナーを表示する
  // FIXME: showMideiumBannerとか大きさを表すメソッドを複数作るのが良さそう？
  // バナーはWidgetじゃないので使いにくいな。。。
  // バナーを表示しようとしている(まだ表示されてはいない)とき、別の画面(バナーを表示したくない画面)に遷移すると、その画面で表示してしまう。
  // アプリ起動中ずっと表示するならありかもしれない。
  Future<bool> showBanner(User user);

  Future<bool> removeBanner();

  Future<bool> loadInterstitial(User user);

  Future<bool> showInterstitial(User user);
}

class AdsUseCaseImpl implements AdsUseCase {
  final AdsRepository adsRepository;

  AdsUseCaseImpl(this.adsRepository);

  @override
  Future<bool> dispose() => adsRepository.dispose();

  @override
  Future<bool> removeBanner() {
    return adsRepository.removeBanner();
  }

  @override
  Future<bool> showBanner(User user) {
    if (!user.paidPlan.isDisplayAd) {
      return Future.value(false);
    }

    // TODO: paidTypeによって非表示するかどうか切り替えたいので、paidtypeをセットしてやる必要がある
    // user.paidPlan.paidType　
    return adsRepository.showBanner();
  }

  @override
  Future<bool> loadInterstitial(User user) {
    if (!user.paidPlan.isDisplayAd) {
      return Future.value(false);
    }
    return adsRepository.loadInterstitial();
  }

  @override
  Future<bool> showInterstitial(User user) {
    if (!user.paidPlan.isDisplayAd) {
      return Future.value(false);
    }

    if (Random().nextInt(100) <= 20) {
      return adsRepository.showInterstitial();
    }
    return Future.value(false);
  }
}
