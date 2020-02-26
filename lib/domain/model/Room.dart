import 'package:instantonnection/domain/model/Message.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:uuid/uuid.dart';

class Room {
  String id;
  String name;
  DateTime createdAt;
  List<RoomUser> members;
  String photoUrl;

  /// 最後のメッセージ
  Message lastMessage;

  /// Roomのメッセージ数
  int messageCount;

  /// 通知するか
  bool get isNotify => members
      .firstWhere((member) => member.isMine,
          orElse: () => RoomUser(isNotify: false))
      .isNotify;

  set isNotify(bool value) =>
      members.firstWhere((member) => member.isMine).isNotify = value;

  RoomUser get myRoomUser =>
      members.firstWhere((member) => member.isMine, orElse: () => RoomUser());

  set myRoomUser(RoomUser value) {
    members = members.where((member) => member.isMine).map((roomUser) {
      return roomUser = value;
    }).toList();
  }

  Room({
    this.name,
    this.id,
    this.createdAt,
    this.members,
    this.photoUrl,
    this.lastMessage,
  }) {
    this.id = this.id ?? Uuid().v4();
    this.createdAt = this.createdAt ?? DateTime.now();
  }

  Room copy(
      {String name,
      String id,
      DateTime createdAt,
      List<User> detailedMembers,
      Uri photoUri}) {
    return Room(
      name: name ?? this.name,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUri ?? this.photoUrl,
    );
  }
}

class RoomUser {
  String userId;
  String name;
  String photoUrl;
  bool isNotify;
  bool isMine = false;

  RoomUser(
      {this.userId,
      this.name,
      this.photoUrl,
      this.isNotify = false,
      this.isMine = false});
}
