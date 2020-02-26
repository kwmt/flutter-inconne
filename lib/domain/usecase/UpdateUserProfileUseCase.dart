import 'dart:async';

import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/repository/AuthRepository.dart';
import 'package:instantonnection/domain/repository/RoomRepository.dart';
import 'package:instantonnection/domain/repository/UserRepository.dart';

/// ユーザーのプロフィールを更新する。
abstract class UpdateUserProfileUseCase {
  Future<bool> execute(User user, {List<Room> rooms});
}

class UpdateUserProfileUseCaseImpl implements UpdateUserProfileUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final RoomRepository _roomRepository;

  UpdateUserProfileUseCaseImpl(
      this._authRepository, this._userRepository, this._roomRepository);

  @override
  Future<bool> execute(User user, {List<Room> rooms}) async {
    List<Future> futureList = List();
    if (rooms != null) {
      List<Future<bool>> updateMemberOfRoomFutureList = rooms.map((room) {
        return _roomRepository.addMemberOfRoom(room, user);
      }).toList();
      futureList.addAll(updateMemberOfRoomFutureList);
    }
    futureList.add(_authRepository.updateUserProfile(user));
    futureList.add(_userRepository.update(user));

    await Future.wait(futureList);
    return Future.value(true);
  }
}
