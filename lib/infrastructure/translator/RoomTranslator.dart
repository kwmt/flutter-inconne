import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/infrastructure/entity/RoomEntity.dart';
import 'package:instantonnection/infrastructure/entity/RoomUserEntity.dart';
import 'package:instantonnection/infrastructure/translator/MessageTranslator.dart';
import 'package:instantonnection/infrastructure/translator/RoomUserTranslator.dart';

class RoomTranslator {
  RoomUserTranslator _roomUserTranslator = RoomUserTranslator();

  RoomEntity toEntity(Room room) {
    List<RoomUserEntity> roomMemberEntityList = room.members
        .map((member) => _roomUserTranslator.toEntity(room, member))
        .toList();

    return RoomEntity(
      room.id,
      room.name,
      room.createdAt,
      roomMemberEntityList,
      room.lastMessage != null
          ? MessageTranslator().toEntity(room.lastMessage)
          : null,
      photoUrl: room.photoUrl,
    );
  }

  List<Room> toModelList(List<RoomEntity> roomEntityList) {
    return roomEntityList.map((roomEntity) {
      return toModel(roomEntity);
    }).toList();
  }

  Room toModel(RoomEntity roomEntity) {
    return Room(
      name: roomEntity.name,
      id: roomEntity.id,
      createdAt: roomEntity.createdAt,
      members: roomEntity.members
          .map((member) => _roomUserTranslator.toModel(member))
          .toList(),
      photoUrl: roomEntity.photoUrl,
      lastMessage: roomEntity.lastMessage != null
          ? MessageTranslator().toModel(roomEntity.lastMessage)
          : null,
    );
  }
}
