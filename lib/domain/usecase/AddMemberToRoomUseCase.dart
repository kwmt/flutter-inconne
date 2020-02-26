import 'dart:async';

import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/model/exception/AddMemberException.dart';
import 'package:instantonnection/domain/repository/RoomRepository.dart';

abstract class AddMemberToRoomUseCase {
  Future<bool> execute(Room room, User user);
}

class AddMemberToRoomUseCaseImpl implements AddMemberToRoomUseCase {
  final RoomRepository roomRepository;

  AddMemberToRoomUseCaseImpl(this.roomRepository);

  @override
  Future<bool> execute(Room room, User user) async {
    try {
      // この順番じゃないとFirestoreのセキュリティルール的にダメ
      await this.roomRepository.addMemberOfRoom(room, user);
      await this.roomRepository.addMemberToRoom(room.id, user);
      return Future.value(true);
    } catch (error) {
      throw AddMemberException(message: error.toString());
    }
  }
}
