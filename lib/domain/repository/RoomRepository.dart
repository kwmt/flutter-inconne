import 'dart:async';

import 'package:instantonnection/domain/model/Message.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/presentation/report/ReportScreen.dart';

abstract class RoomRepository {
  /// Roomリストを取得する
  /// @return Roomリスト
  Future<List<Room>> fetchRoomList(User user);

  // [roomId]のRoomを取得する
  Future<Room> fetchRoom(String roomId, User user);

  /// Roomのメンバーリストを取得する
  Future<List<User>> fetchMemberListOfRoom(Room room);

  /// Roomリストを監視する
  StreamSubscription watchRoomList(User user, void onChange(List<Room> room));

  /// Roomを監視する。
  StreamSubscription watchRoom(
      Room room, User user, void onChange(List<Message> message));

  /// 新規チャットルームを作成する
  Future<bool> createNewRoom(Room room, User user);

  /// Roomを更新する
  Future<bool> updateRoom(Room room);

  /// Roomのlatest messageを更新する
  Future<bool> updateLatestMessage(Room room, Message message);

  /// Roomにメンバーを追加する
  Future<bool> addMemberToRoom(String roomId, User user);

  Future<bool> deleteMemberRoom(Room room, User user);

  /// Roomのmembersサブコレクションにメンバーを追加する
  Future<bool> addMemberOfRoom(Room room, User user);

  /// Roomのmembersサブコレクションからメンバーを削除する
  Future<bool> deleteMemberFromRoom(Room room, User user);

  /// Roomのメンバー情報を更新する
  Future<RoomUser> updateRoomUser(Room room);

  /// 新規メッセージを作成する
  Future<bool> createNewMessage(Room room, Message message);

  /// ルームを通報する
  Future<void> reportRoom(User user, Room room, ReportType type);

  /// メッセージ（コンテンツ）を通報する
  Future<void> reportMessage(User user, Room room, Message message, ReportType type);
}
