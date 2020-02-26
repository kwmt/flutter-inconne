import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:instantonnection/presentation/common/Screen.dart';

class AnalyticsHelper {
  static final AnalyticsHelper _instance = AnalyticsHelper._internal(
      Injector.getInjector().get<FirebaseAnalytics>());

  AnalyticsHelper._internal(this.analytics);

  static AnalyticsHelper get instance => _instance;

  static FirebaseAnalyticsObserver get observer =>
      Injector.getInjector().get<FirebaseAnalyticsObserver>();

  final FirebaseAnalytics analytics;

  Future<void> sendCurrentScreen(Screen screenName) {
    if (screenName == null) {
      return Future.value();
    }
    return observer.analytics.setCurrentScreen(
      screenName: screenName.name,
    );
  }

  /// Roomに参加
  Future<void> sendJoinRoom(String roomId) {
    return analytics.logEvent(
      name: 'join_room',
      parameters: <String, dynamic>{
        'room_id': roomId,
      },
    );
  }

  // テーマカラー変更
  Future<void> sendChangeTheme(String themeId) async {
    return analytics.logEvent(
      name: 'change_theme',
      parameters: <String, dynamic>{
        'theme_id': themeId,
      },
    );
  }

  // ユーザー変更
  Future<void> sendChangeUser() async {
    return analytics.logEvent(name: 'change_user');
  }

  // Room変更
  Future<void> sendChangeRoom() async {
    return analytics.logEvent(name: 'change_room');
  }
}
