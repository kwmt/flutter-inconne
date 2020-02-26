import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:instantonnection/domain/model/PushMessage.dart';
import 'package:instantonnection/domain/repository/PushNotificationRepository.dart';
import 'package:instantonnection/infrastructure/entity/PushMessageEntity.dart';
import 'package:instantonnection/infrastructure/translator/PushMessageTranslator.dart';

class FirebaseMessagingDatasource implements PushNotificationRepository {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final PushMessageTranslator pushMessageTranslator = PushMessageTranslator();

  FirebaseMessagingDatasource() {
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
  }

  StreamController<PushMessage> _messageTypeStreamController =
      StreamController.broadcast();

  @override
  Stream<PushMessage> config() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        PushMessageEntity pushMessageEntity = PushMessageEntity.fromJSON(
            PushMessageType.Message, message['data']);
        _messageTypeStreamController
            .add(pushMessageTranslator.toModel(pushMessageEntity));
      },
      onLaunch: (Map<String, dynamic> message) async {
        PushMessageEntity pushMessageEntity =
            PushMessageEntity.fromJSON(PushMessageType.Launch, message);
        _messageTypeStreamController
            .add(pushMessageTranslator.toModel(pushMessageEntity));
      },
      onResume: (Map<String, dynamic> message) async {
        PushMessageEntity pushMessageEntity =
            PushMessageEntity.fromJSON(PushMessageType.Resume, message);
        _messageTypeStreamController
            .add(pushMessageTranslator.toModel(pushMessageEntity));
      },
    );
    return _messageTypeStreamController.stream;
  }

  @override
  Future<void> requestNotificationPermissions() {
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    return Future.value();
  }

  @override
  Future<String> getToken() => _firebaseMessaging.getToken();

  @override
  Future<void> subscribeToTopic(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
    return Future.value();
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) {
    _firebaseMessaging.unsubscribeFromTopic(topic);
    return Future.value();
  }
}
