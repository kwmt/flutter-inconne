import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/infrastructure/entity/RoomUserEntity.dart';

class RoomUserTranslator {
  RoomUserEntity toEntity(Room room, RoomUser user) {
    return RoomUserEntity(
        userId: user.userId,
        name: user.name,
        photoUrl: user.photoUrl,
        isNotify: room.isNotify,
        isMine: user.isMine);
  }

  RoomUserEntity roomUserToEntity(RoomUser roomUser) {
    return RoomUserEntity(
        userId: roomUser.userId,
        name: roomUser.name,
        photoUrl: roomUser.photoUrl,
        isNotify: roomUser.isNotify,
        isMine: roomUser.isMine);
  }

  RoomUser toModel(RoomUserEntity roomUserEntity) {
    return RoomUser(
        userId: roomUserEntity.userId,
        name: roomUserEntity.name,
        photoUrl: roomUserEntity.photoUrl,
        isNotify: roomUserEntity.isNotify,
        isMine: roomUserEntity.isMine);
  }
}
