import 'dart:async';

import 'package:instantonnection/domain/model/AppTheme.dart';
import 'package:instantonnection/domain/model/BlockUser.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';

abstract class UserRepository {
  Future<User> createNewUser(User user);

  Future<String> createNotificationToken(User user, String token);

  Future<User> fetchUser(User user);

  Future<List<AppTheme>> fetchThemes();

  Future<BlockUserList> fetchBlockUsers(User user);

  /// userがroomUserをブロックする
  Future<void> addBlockUser(User user, RoomUser roomUser);

  /// userがblockUserを解除する
  Future<void> removeBlockUser(User user, RoomUser blockUser);

  /// インコネデータベースにあるユーザー情報を更新する
  Future<bool> update(User user);
}
