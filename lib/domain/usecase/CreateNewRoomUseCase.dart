import 'dart:async';
import 'dart:io';

import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/repository/RoomRepository.dart';
import 'package:instantonnection/domain/repository/UserRepository.dart';
import 'package:instantonnection/domain/usecase/UpdatePushNotificationSubscriptionUseCase.dart';
import 'package:instantonnection/domain/usecase/UploadImageUseCase.dart';

/// 新規Roomを作成する
abstract class CreateNewRoomUseCase {
  /// 画像があればアップロードして、
  /// 新規Roomを作成後Room件数をカウントアップする
  /// また、同時にプッシュ通知の登録をする
  /// @param なんというRoomを作るのか
  Future<bool> execute(Room room, User user, {File imageFile});
}

class CreateNewRoomUseCaseImpl implements CreateNewRoomUseCase {
  final RoomRepository roomRepository;
  final UserRepository _userRepository;

  final UploadImageUseCase _uploadImageUseCase;
  final UpdatePushNotificationSubscriptionUseCase
      _updatePushNotificationSubscriptionUseCase;

  CreateNewRoomUseCaseImpl(
      this.roomRepository,
      this._userRepository,
      this._uploadImageUseCase,
      this._updatePushNotificationSubscriptionUseCase);

  @override
  Future<bool> execute(Room room, User user, {File imageFile}) async {
    if (imageFile != null) {
      return _uploadImageUseCase.room(imageFile, room, user).then(
          (uploadTask) => uploadTask.ref
              .getDownloadURL()
              .then((photoUrl) => room..photoUrl = photoUrl)
              .then((room) => _createRoom(room, user)));
    }
    // Roomを作りながら、topicに登録する
    return _createRoom(room, user);
  }

  Future<bool> _createRoom(Room room, User user) async {
    List<String> topics = List<String>()..add(room.id)..add(user.uid);
    room.members = [user.toRoomUser(isNotify: true, isMine: true)];

    Future<bool> _createNewRoom =
        roomRepository.createNewRoom(room, user).then((success) {
      return _updateCreatedRoomCount(user);
    });

    List<dynamic> results = await Future.wait([
      _createNewRoom,
      _updatePushNotificationSubscriptionUseCase.subscribeTopics(topics)
    ]);
    return results[0];
  }

  /// Room数をカウントアップ
  Future<bool> _updateCreatedRoomCount(User user) {
    user.paidPlan.createdRoomCount++;
    return _userRepository.update(user);
  }
}
