import 'package:instantonnection/infrastructure/datasource/util/DateTime.dart';
import 'package:instantonnection/infrastructure/entity/MessageEntity.dart';
import 'package:instantonnection/infrastructure/entity/RoomUserEntity.dart';

class RoomEntity {
  String id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;
  List<RoomUserEntity> members;

  String photoUrl;
  MessageEntity _lastMessage;

  MessageEntity get lastMessage {
    if (_lastMessage == null) {
      return null;
    }
    return _lastMessage
      ..roomUser = members.firstWhere(
          (member) => _lastMessage.fromUserId == member.userId,
          orElse: () => RoomUserEntity());
  }

  set lastMessage(MessageEntity messageEntity) {
    _lastMessage = messageEntity;
  }

  RoomEntity(
      this.id, this.name, this.createdAt, this.members, this._lastMessage,
      {this.photoUrl});

  RoomEntity.only({this.id, this.name, this.createdAt});

  RoomEntity.fromJSON(Map json, String id) {
    List<RoomUserEntity> roomMembers =
        json['members'].keys.map<RoomUserEntity>((uid) {
      return RoomUserEntity(userId: uid);
    }).toList();

    this.id = id;
    this.name = json['name'];
    this.createdAt = DateTimeUtil.parseTime(json['created_at']);
    this.members = roomMembers;
    this.photoUrl = json['photo_url'] != 'null' ? json['photo_url'] : null;
    this.updatedAt = DateTimeUtil.parseTime(json['updated_at']);
    this._lastMessage = json['last_message'] != null
        ? MessageEntity.fromJSON(json['last_message'], null)
        : null;
  }

  toObject() => <String, dynamic>{
        'id': id,
        'name': name,
        'created_at': createdAt,
        'members': toMembersObject(),
        'photo_url': photoUrl,
        'updated_at': DateTime.now(),
        'last_message': lastMessage != null ? lastMessage.toObject() : null,
      };

  toMembersObject() => Map.fromIterable(members,
      key: (member) => member.userId, value: (_) => true);
}
