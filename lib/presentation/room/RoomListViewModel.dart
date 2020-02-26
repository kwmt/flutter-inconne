import 'dart:async';

import 'package:instantonnection/domain/model/PushMessage.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/usecase/ConfigurePushNotificationUseCase.dart';
import 'package:instantonnection/domain/usecase/FetchRoomListUseCase.dart';
import 'package:instantonnection/domain/usecase/LeaveRoomUseCase.dart';
import 'package:instantonnection/domain/usecase/UpdatePushNotificationSubscriptionUseCase.dart';

class ViewState {
  ViewType viewType = ViewType.LOADING;

  List<Room> roomList;

  ViewState(this.viewType, this.roomList);

  static ViewState get initState => ViewState(ViewType.LOADING, null);
}

class Push {
  PushMessage pushMessage;
  Room room;

  Push(this.pushMessage, this.room);
}

enum ViewType { LOADING, ROOMLIST }

abstract class RoomListViewModel {
  Stream<ViewState> get viewState;

  Future<void> fetchRoomList(User user);

  StreamSubscription watchRoomList(User user);

  Future<void> updatePushNotificationSubscription(Room room, User user);

  Stream<Push> watchPushNotification();

  Future<void> requestNotificationPermissions();

  Future<String> registerToken(User user);

  Future<void> leaveRoom(Room room, User user);

  void init();

  void dispose();
}

class RoomListViewModelImpl implements RoomListViewModel {
  final FetchRoomListUseCase _fetchRoomListUseCase;
  final UpdatePushNotificationSubscriptionUseCase
      _pushNotificationSubscriptionUseCase;
  final ConfigurePushNotificationUseCase _configurePushNotificationUseCase;
  final LeaveRoomUseCase _leaveRoomUseCase;

  StreamController<ViewState> _roomListController;

  List<Room> _roomList = List();

  final ViewState _state = ViewState.initState;

  @override
  Stream<ViewState> get viewState => _roomListController.stream;

  RoomListViewModelImpl(
      this._fetchRoomListUseCase,
      this._pushNotificationSubscriptionUseCase,
      this._configurePushNotificationUseCase,
      this._leaveRoomUseCase);

  @override
  void init() {
    if (_roomListController == null ||
        (_roomListController != null && _roomListController.isClosed)) {
      _roomListController = StreamController.broadcast();
    }
  }

  @override
  Future<void> fetchRoomList(User user) async {
    _fetchRoomList(user);
  }

  Future<void> _fetchRoomList(User user) async {
    _roomListController.add(ViewState.initState);
    List<Room> roomList = await _fetchRoomListUseCase.execute(user);
    this._roomList = roomList;
    _state
      ..viewType = ViewType.ROOMLIST
      ..roomList = roomList;
    _roomListController.add(_state);
  }

  @override
  StreamSubscription watchRoomList(User user) {
    return _watchRoomList(user);
  }

  StreamSubscription _watchRoomList(User user) {
    return _fetchRoomListUseCase.watch(user, (List<Room> roomList) {
      this._roomList = roomList;
      _state
        ..viewType = ViewType.ROOMLIST
        ..roomList = roomList;
      _roomListController.add(_state);
    });
  }

  @override
  void dispose() {
//    _roomListController?.close();
//    _watchSubscription.cancel();
  }

  @override
  Future<void> updatePushNotificationSubscription(Room room, User user) async {
    await _pushNotificationSubscriptionUseCase.execute(room);
    await _fetchRoomList(user);
    return Future.value();
  }

  @override
  Stream<Push> watchPushNotification() {
    return _configurePushNotificationUseCase.execute().map((pushMessage) {
      Room room = _roomList.firstWhere((room) => room.id == pushMessage.roomId);
      return Push(pushMessage, room);
    });
  }

  @override
  Future<void> requestNotificationPermissions() {
    return _configurePushNotificationUseCase.requestNotificationPermissions();
  }

  @override
  Future<String> registerToken(User user) {
    return _configurePushNotificationUseCase.registerToken(user);
  }

  @override
  Future<void> leaveRoom(Room room, User user) {
    return _leaveRoomUseCase.execute(room, user);
  }
}
