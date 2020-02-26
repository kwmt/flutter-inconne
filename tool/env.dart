import 'dart:convert';
import 'dart:io';

/// `% dart tool/env.dart` で、`tool/.env.dart`ファイルを作成します。
///
Future<void> main() async {
  final fileName = 'lib/.env.dart';
  const iOS = "iOS";
  const android = "Android";
  const googleAppID = "googleAppID";
  const googleApiKey = "googleApiKey";
  const googleProjectId = "googleProjectId";
  const firebaseStorageBucket = "firebaseStorageBucket";
  const adMobIds = "adMobIds";
  const appId = "appId";
  const interstitialUnitId = "interstitialUnitId";
  const baseWebUrl = "baseWebUrl";
  const baseSubscriptionApiUrl = "baseSubscriptionApiUrl";

  final config = {
    googleAppID: {
      iOS: Platform.environment['GOOGLE_APP_ID_IOS'],
      android: Platform.environment['GOOGLE_APP_ID_ANDROID'],
    },
    googleApiKey: Platform.environment['GOOGLE_API_KEY'],
    googleProjectId: Platform.environment['GOOGLE_PROJECT_ID'],
    firebaseStorageBucket: Platform.environment['FIREBASE_STORAGE_BUCKET'],
    adMobIds: {
      appId: {
        iOS: Platform.environment['ADMOB_IDS_IOS'],
        android: Platform.environment['ADMOB_IDS_ANDROID']
      },
      interstitialUnitId: {
        iOS: Platform.environment['INTERSTITIAL_UNIT_IOS'],
        android: Platform.environment['INTERSTITIAL_UNIT_ANDROID']
      },
    },
    baseWebUrl: Platform.environment['BASE_WEB_URL'],
    baseSubscriptionApiUrl: Platform.environment['BASE_SUBSCRIPTION_API_URL'],
  };

  var cls = "class EnvKey { \n" +
      "  static const $iOS = ${json.encode(iOS)};\n" +
      "  static const $android = ${json.encode(android)};\n" +
      "  static const $googleAppID = ${json.encode(googleAppID)};\n" +
      "  static const $googleApiKey = ${json.encode(googleApiKey)};\n" +
      "  static const $googleProjectId = ${json.encode(googleProjectId)};\n" +
      "  static const $firebaseStorageBucket = ${json.encode(firebaseStorageBucket)};\n" +
      "  static const $adMobIds = ${json.encode(adMobIds)};\n" +
      "  static const $appId = ${json.encode(appId)};\n" +
      "  static const $interstitialUnitId = ${json.encode(interstitialUnitId)};\n" +
      "  static const $baseWebUrl = ${json.encode(baseWebUrl)};\n" +
      "  static const $baseSubscriptionApiUrl = ${json.encode(baseSubscriptionApiUrl)};\n" +
      "}";
  var content = '$cls\n\nfinal environment = ${json.encode(config)};';

  File(fileName).writeAsString(content);
}
