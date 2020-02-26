import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:instantonnection/application/AppConfig.dart';
import 'package:instantonnection/application/di.dart';
import 'package:instantonnection/application/main_common.dart';
import 'package:instantonnection/.env.dart';

void main() async {
  Map<String, String> googleAppID = environment[EnvKey.googleAppID];
  var config = AppConfig(
    flavor: Flavor.DEVELOPMENT,
    title: '[開発]インコネ',
    googleAppID: Platform.isIOS
        ? checkEnvironment(googleAppID[EnvKey.iOS])
        : checkEnvironment(googleAppID[EnvKey.Android]),
    googleApiKey: checkEnvironment(environment[EnvKey.googleApiKey]),
    googleProjectId: checkEnvironment(environment[EnvKey.googleProjectId]),
    firebaseStorageBucket:
        checkEnvironment(environment[EnvKey.firebaseStorageBucket]),
    adMobIds: AdMobIds(
        appId: FirebaseAdMob.testAppId,
        bannerUnitId: BannerAd.testAdUnitId,
        interstitialUnitId: InterstitialAd.testAdUnitId),
    baseWebUrl: checkEnvironment(environment[EnvKey.baseWebUrl]),
    baseSubscriptionApiUrl:
        checkEnvironment(environment[EnvKey.baseSubscriptionApiUrl]),
    child: MyApp(),
  );

  await mainCommon(config);

  await DependencyInjection().initialize(config);

  setupCrashlyticsAndRunApp(config);
}
