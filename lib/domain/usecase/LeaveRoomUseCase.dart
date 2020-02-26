import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/model/exception/LeaveRoomException.dart';
import 'package:instantonnection/domain/repository/PushNotificationRepository.dart';
import 'package:instantonnection/domain/repository/RoomRepository.dart';

/// Roomから退出するUseCase
abstract class LeaveRoomUseCase {
  /// @param room どの部屋から退出するか
  /// @param user 誰が退出するか
  Future<bool> execute(Room room, User user);
}

class LeaveRoomUseCaseImpl implements LeaveRoomUseCase {
  final RoomRepository _roomRepository;

  final PushNotificationRepository _pushNotificationRepository;

  LeaveRoomUseCaseImpl(this._roomRepository, this._pushNotificationRepository);

  @override
  Future<bool> execute(Room room, User user) async {
    room.isNotify = false; // unsubscribeしたいのでfalseを設定する
    room.members.removeWhere((roomUser) => roomUser.userId == user.uid);
    try {
      await _roomRepository.deleteMemberRoom(room, user);
      await _roomRepository.deleteMemberFromRoom(room, user);
      await _pushNotificationRepository.unsubscribeFromTopic(room.id);
    } catch (error) {
      throw LeaveRoomException();
    }
    return Future.value(true);
  }
}
