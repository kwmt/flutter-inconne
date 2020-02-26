abstract class AdsRepository {
  Future<bool> dispose();

  Future<bool> showBanner();

  Future<bool> removeBanner();

  /// たとえば、Interstitial広告を閉じたタイミングとかでloadしておくと良いかもしれない？
  /// あるいは、
  Future<bool> loadInterstitial();

  Future<bool> showInterstitial();
}
