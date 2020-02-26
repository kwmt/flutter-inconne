import 'dart:io';

import 'package:flutter/material.dart';
import 'package:instantonnection/domain/model/AppPackageInfo.dart';
import 'package:instantonnection/domain/model/AppTheme.dart';
import 'package:instantonnection/domain/model/PaidPlan.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/model/util/EnumUtil.dart';

enum Flavor { DEVELOPMENT, PRODUCTION }

class AppConfig extends InheritedWidget {
  static Color primaryColor = Colors.teal;
  static Color secondaryColor = Color(0xFF00964b);

  static final ColorScheme colorScheme = const ColorScheme.dark().copyWith(
    primary: primaryColor,
    secondary: secondaryColor,
  );

  // ignore: must_be_immutable
  static ThemeData kTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: primaryColor,
      accentColor: Colors.redAccent,
      buttonTheme: ButtonThemeData(
        colorScheme: colorScheme,
        textTheme: ButtonTextTheme.primary,
      )
  );

  static void setAppTheme(AppTheme appTheme) {
    AppConfig.kTheme = AppConfig.kTheme.copyWith(
      primaryColor: appTheme.primary,
      accentColor: appTheme.accent,
      buttonTheme: ButtonThemeData(
          colorScheme: AppConfig.colorScheme
              .copyWith(primary: appTheme.primary)),
    );
  }

  AppConfig(
      {this.flavor,
      this.title,
      this.googleAppID,
      this.googleApiKey,
      this.googleProjectId,
      this.firebaseStorageBucket,
      this.adMobIds,
      this.baseWebUrl,
      this.baseSubscriptionApiUrl,
      this.appPackageInfo,
      Widget child})
      : super(child: child);

  static AppConfig of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(AppConfig);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  final Flavor flavor;
  final String title;
  final String googleAppID;
  final String googleApiKey;
  final String googleProjectId;
  final String firebaseStorageBucket;
  final String baseWebUrl;
  final String baseSubscriptionApiUrl;
  final AdMobIds adMobIds;

  AppPackageInfo appPackageInfo;

  String get privacyPolicyUrl =>  "${this.baseWebUrl}/privacy-policy.html";
  String get termsUrl => "${this.baseWebUrl}/terms-of-service.html?platform=$platformString";
  String get helpUrl =>  "${this.baseWebUrl}/help.html?platform=$platformString";

  String get freePlan => EnumUtil.getValueString(PaidType.Free);
  String get productAdPlan => "${this.appPackageInfo.packageName}.product.ad";
  String get litePlan => "${this.appPackageInfo.packageName}.subscription.lite";
  String get proPlan => "${this.appPackageInfo.packageName}.subscription.pro";
  String get unlimitedPlan =>
      "${this.appPackageInfo.packageName}.subscription.unlimited";

  String get platformString => Platform.isIOS ? "apple" : "google";

//  User _user;
//  User get user => _user;
//  set user(User user) {
//    _user = user;
//  }
  
}

/// AdMobのID郡
class AdMobIds {
  final String appId;
  final String bannerUnitId;
  final String interstitialUnitId;

  AdMobIds({this.appId, this.bannerUnitId, this.interstitialUnitId});
}
