import 'dart:async';

import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/repository/PushNotificationRepository.dart';
import 'package:instantonnection/domain/repository/RoomRepository.dart';

/// Push通知のトピックのサブスクリプション状態を更新する
abstract class UpdatePushNotificationSubscriptionUseCase {
  Future<void> subscribeTopics(List<String> topics);

  Future<void> unsubscribeTopics(List<String> topics);

  Future<List<dynamic>> subscribe(String topic, Room room);

  Future<List<dynamic>> unsubscribe(String topic, Room room);

  Future<void> subscribeBlockTopic();

  Future<void> unsubscribeBlockTopic();

  /// Push通知を更新したいRoomIdと、isNotifyがtrueならsubscribe, falseならunsubscribeする。
  Future<RoomUser> execute(Room updatedRoom);
}

class UpdatePushNotificationSubscriptionUseCaseImpl
    implements UpdatePushNotificationSubscriptionUseCase {
  final PushNotificationRepository _pushNotificationRepository;
  final RoomRepository _roomRepository;

  UpdatePushNotificationSubscriptionUseCaseImpl(
      this._pushNotificationRepository, this._roomRepository);

  @override
  Future<void> subscribeTopics(List<String> topics) {
    List<Future<void>> subscribeFutures = topics.map((topic) {
      return _pushNotificationRepository.subscribeToTopic(topic);
    }).toList();
    return Future.wait(subscribeFutures);
  }

  @override
  Future<void> unsubscribeTopics(List<String> topics) {
    List<Future<void>> unsubscribeFutures = topics.map((topic) {
      return _pushNotificationRepository.unsubscribeFromTopic(topic);
    }).toList();
    return Future.wait(unsubscribeFutures);
  }

  @override
  Future<List<dynamic>> subscribe(String topic, Room room) {
    return Future.wait([
      _pushNotificationRepository.subscribeToTopic(topic),
      _roomRepository.updateRoomUser(room)
    ]);
  }

  @override
  Future<List<dynamic>> unsubscribe(String topic, Room room) {
    return Future.wait([
      _pushNotificationRepository.unsubscribeFromTopic(topic),
      _roomRepository.updateRoomUser(room)
    ]);
  }

  @override
  Future<void> subscribeBlockTopic() {
    return _pushNotificationRepository.subscribeToTopic("block");
  }

  @override
  Future<void> unsubscribeBlockTopic() {
    return _pushNotificationRepository.unsubscribeFromTopic("block");  }

  @override
  Future<RoomUser> execute(Room updatedRoom) async {
    String topic = updatedRoom.id;
    List<dynamic> results;
    if (updatedRoom.isNotify) {
      results = await subscribe(topic, updatedRoom);
    } else {
      results = await unsubscribe(topic, updatedRoom);
    }
    if (results.length >= 2) {
      RoomUser roomUser = results[1] as RoomUser;
      return roomUser;
    }
    // FIXME: 更新に失敗しているので、例外をスローするなどしたほうが良いかもしれない。
    return null;
  }
}
