import 'dart:io';

import 'package:instantonnection/application/AppConfig.dart';
import 'package:instantonnection/application/di.dart';
import 'package:instantonnection/application/main_common.dart';
import 'package:instantonnection/.env.dart';

void main() async {
  Map<String, String> googleAppID = environment[EnvKey.googleAppID];
  Map<String, Map<String, String>> adMobIds = environment[EnvKey.adMobIds];
  Map<String, String> adMobAppId = adMobIds[EnvKey.appId];
  Map<String, String> adMobInterstitialUnitId =
      adMobIds[EnvKey.interstitialUnitId];
  var config = AppConfig(
    flavor: Flavor.PRODUCTION,
    title: 'インコネ',
    googleAppID: Platform.isIOS
        ? checkEnvironment(googleAppID[EnvKey.iOS])
        : checkEnvironment(googleAppID[EnvKey.Android]),
    googleApiKey: checkEnvironment(environment[EnvKey.googleApiKey]),
    googleProjectId: checkEnvironment(environment[EnvKey.googleProjectId]),
    firebaseStorageBucket:
        checkEnvironment(environment[EnvKey.firebaseStorageBucket]),
    adMobIds: AdMobIds(
        appId: Platform.isAndroid
            ? adMobAppId[EnvKey.Android]
            : adMobAppId[EnvKey.iOS],
        bannerUnitId: "TODO",
        interstitialUnitId: Platform.isAndroid
            ? adMobInterstitialUnitId[EnvKey.Android]
            : adMobInterstitialUnitId[EnvKey.iOS]),
    baseWebUrl: checkEnvironment(environment[EnvKey.baseWebUrl]),
    baseSubscriptionApiUrl:
    checkEnvironment(environment[EnvKey.baseSubscriptionApiUrl]),
    child: MyApp(),
  );

  await mainCommon(config);
  await DependencyInjection().initialize(config);

  setupCrashlyticsAndRunApp(config);
}
