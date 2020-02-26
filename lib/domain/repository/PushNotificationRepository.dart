import 'dart:async';

import 'package:instantonnection/domain/model/PushMessage.dart';

abstract class PushNotificationRepository {
  Stream<PushMessage> config();

  Future<void> requestNotificationPermissions();

  Future<String> getToken();

  Future<void> subscribeToTopic(String topic);

  Future<void> unsubscribeFromTopic(String topic);
}
