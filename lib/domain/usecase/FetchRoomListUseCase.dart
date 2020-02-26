import 'dart:async';

import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/repository/RoomRepository.dart';

/// ユーザーのRoomリストを取得する
abstract class FetchRoomListUseCase {
  Future<List<Room>> execute(User user);

  /// Roomリストを監視する。Roomリストに変更(追加・削除)があれば`onChange`に通知される。
  StreamSubscription watch(User user, onChange(List<Room> rooms));
}

class FetchRoomListUseCaseImpl implements FetchRoomListUseCase {
  final RoomRepository _roomRepository;

  FetchRoomListUseCaseImpl(this._roomRepository);

  @override
  Future<List<Room>> execute(User user) {
    return _roomRepository.fetchRoomList(user);
  }

  @override
  StreamSubscription watch(User user, Function(List<Room> rooms) onChange) {
    return _roomRepository.watchRoomList(user, (List<Room> rooms) {
      onChange(rooms);
    });
  }
}
