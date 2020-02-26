import 'dart:async';

import 'package:instantonnection/domain/model/Message.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/repository/RoomRepository.dart';

/// メッセージを送信する
abstract class CreateNewMessageUseCase {
  Future<bool> execute(Room room, Message message);
}

class CreateNewMessageUseCaseImpl implements CreateNewMessageUseCase {
  final RoomRepository roomRepository;

  CreateNewMessageUseCaseImpl(this.roomRepository);

  @override
  Future<bool> execute(Room room, Message message) {
    return roomRepository.createNewMessage(room, message);
  }
}
