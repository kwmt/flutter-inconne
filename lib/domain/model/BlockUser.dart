//class BlockUser {
//  String id;
//  String photoUrl;
//  String name;
//
//  BlockUser(this.id, this.photoUrl, this.name);
//}

import 'package:instantonnection/domain/model/Room.dart';

class BlockUserList {
  List<RoomUser> _blockUsers;

  BlockUserList(this._blockUsers);

  List<RoomUser> get blockUsers => _blockUsers;

  int get count => _blockUsers != null ? _blockUsers.length : 0;

  RoomUser blockUser(int position) {
    if (_blockUsers != null && position < _blockUsers.length) {
      return blockUsers[position];
    }
    throw ArgumentError();
  }

  bool hasBlockUser(RoomUser roomUser) =>
      // _blockUsersリストの中から指定したroomUserのuserIdが見つかれば、
      // そのユーザーをブロックしているということで、trueを返す。
      _blockUsers
          .where((blockUser) => blockUser.userId == roomUser.userId)
          .length >
      0;

  List<RoomUser> addRoomUser(RoomUser roomUser) => _blockUsers..add(roomUser);

  List<RoomUser> removeRoomUser(RoomUser roomUser) =>
      _blockUsers..remove(roomUser);
}
