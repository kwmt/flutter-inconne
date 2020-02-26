import 'dart:async';

import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/repository/RoomRepository.dart';

abstract class UpdateRoomUseCase {
  Future<bool> execute(Room room);
}

class UpdateRoomUseCaseImpl implements UpdateRoomUseCase {
  final RoomRepository roomRepository;

  UpdateRoomUseCaseImpl(this.roomRepository);

  @override
  Future<bool> execute(Room room) async {
    return this.roomRepository.updateRoom(room);
  }
}
