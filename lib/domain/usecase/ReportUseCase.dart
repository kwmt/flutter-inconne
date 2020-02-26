import 'dart:async';

import 'package:instantonnection/domain/model/Message.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/repository/RoomRepository.dart';
import 'package:instantonnection/presentation/report/ReportScreen.dart';

/// 通報する
abstract class ReportUseCase {
  // ルームを通報する
  Future<void> reportRoom(User user, Room room, ReportType type);

  /// メッセージを通報する
  Future<void> reportMessage(
      User user, Room room, ReportType type, Message message);
}

class ReportRoomUseCaseImpl implements ReportUseCase {
  final RoomRepository _roomRepository;

  ReportRoomUseCaseImpl(this._roomRepository);

  @override
  Future<void> reportRoom(User user, Room room, ReportType type) {
    return _roomRepository.reportRoom(user, room, type);
  }

  @override
  Future<void> reportMessage(
      User user, Room room, ReportType type, Message message) {
    return _roomRepository.reportMessage(user, room, message, type);
  }
}
