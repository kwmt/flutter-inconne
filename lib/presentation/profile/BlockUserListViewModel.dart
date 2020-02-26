import 'dart:async';

import 'package:instantonnection/domain/model/BlockUser.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/usecase/BlockUserUseCase.dart';
import 'package:instantonnection/domain/usecase/UpdatePushNotificationSubscriptionUseCase.dart';

class BlockUserListViewModel {
  User _user;
  final BlockUserUseCase _blockUserUseCase;
  final UpdatePushNotificationSubscriptionUseCase
      _updatePushNotificationSubscriptionUseCase;

  BlockUserListViewModel(this._user, this._blockUserUseCase,
      this._updatePushNotificationSubscriptionUseCase);

  StreamController<BlockUserList> _controller = StreamController.broadcast();

  Stream<BlockUserList> get blockUser => _controller.stream;

  void remove(RoomUser roomUser) async {
    try {
      await Future.wait([
        _blockUserUseCase.removeBlockUser(_user, roomUser),
        _updatePushNotificationSubscriptionUseCase.unsubscribeBlockTopic()
      ]);
      _user.blockUserList.blockUsers.remove(roomUser);
      _controller.add(_user.blockUserList);
    } catch (error) {
      _controller.addError(error);
    }
  }

  void fetchUsers() async {
    try {
      _user.blockUserList = await _blockUserUseCase.fetchBlockUsers(_user);
      _controller.add(_user.blockUserList);
    } catch (error) {
      _controller.addError(error);
    }
  }

  void dispose() {
    _controller.close();
  }
}
