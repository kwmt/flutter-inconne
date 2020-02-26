import 'dart:async';

import 'package:instantonnection/domain/model/Message.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/repository/RoomRepository.dart';

/// Roomのチャットリストを取得する
abstract class FetchChatListOfRoomUseCase {
  /// Roomを監視する。Roomに変更(追加・削除)があれば`onChange`に通知される。
  StreamSubscription watch(
      Room room, User user, onChange(List<Message> messages));
}

class FetchChatListOfRoomUseCaseImpl implements FetchChatListOfRoomUseCase {
  final RoomRepository roomRepository;

  FetchChatListOfRoomUseCaseImpl(this.roomRepository);

  @override
  StreamSubscription watch(
      Room room, User user, onChange(List<Message> messages)) {
    return roomRepository.watchRoom(room, user, (List<Message> messages) {
      onChange(messages);
    });
  }
}
