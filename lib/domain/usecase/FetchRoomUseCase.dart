import 'dart:async';

import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/repository/RoomRepository.dart';

/// ユーザーのRoomを取得する
abstract class FetchRoomUseCase {
  Future<Room> execute(String roomId, User user);
}

class FetchRoomUseCaseImpl implements FetchRoomUseCase {
  final RoomRepository _roomRepository;

  FetchRoomUseCaseImpl(this._roomRepository);

  @override
  Future<Room> execute(String roomId, User user) {
    return _roomRepository.fetchRoom(roomId, user);
  }
}
