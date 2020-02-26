import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instantonnection/application/AppConfig.dart';
import 'package:instantonnection/domain/model/PushMessage.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/BaseScreenState.dart';
import 'package:instantonnection/presentation/common/ExceptionUtil.dart';
import 'package:instantonnection/presentation/common/ImageUtils.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/analytics/AnalyticsHelper.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';
import 'package:instantonnection/presentation/common/progress/Progress.dart';
import 'package:instantonnection/presentation/room/JoinRoomReader.dart';
import 'package:instantonnection/presentation/room/RoomListViewModel.dart';

// ignore: must_be_immutable
class RoomListScreen extends StatefulWidget implements Screen {
  User user;

  final JoinRoomReader joinRoomReader;

  final AppNavigator _appNavigator;

  final RoomListViewModel viewModel;

  RoomListScreen(
      this.user, this.viewModel, this.joinRoomReader, this._appNavigator);

  @override
  _RoomListScreen createState() => _RoomListScreen();

  @override
  String get name => "/rooms";
}

class _RoomListScreen extends BaseScreenState<RoomListScreen> {
  StreamSubscription _watchSubscription;

  @override
  void initState() {
    super.initState();

    if (widget.user == null) {
      return;
    }

    widget.viewModel.init();
    _setupPushNotification();
    widget.viewModel.fetchRoomList(widget.user);

    _watchSubscription = widget.viewModel.watchRoomList(widget.user);
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.viewModel.init();

    Widget body() {
      return StreamBuilder<ViewState>(
        initialData: ViewState.initState,
        stream: widget.viewModel.viewState,
        builder: (context, snapshot) {
          switch (snapshot.data.viewType) {
            case ViewType.LOADING:
              return Progress();
            case ViewType.ROOMLIST:
              return ListView.builder(
                itemCount: snapshot.data.roomList != null
                    ? snapshot.data.roomList.length
                    : 0,
                itemBuilder: (BuildContext context, int position) {
                  return _getSlidableWithLists(
                      context, snapshot.data.roomList[position]);
                },
              );
          }
        },
      );
    }

    Widget screen() {
      if (widget.user == null) {
        return Scaffold(
            appBar: AppBar(
              title: Text(Strings.of(context).pleaseLogin),
            ),
            body: Column(
              children: <Widget>[
                Text(
                    "TODO: ログインしてくださいね的な文言を表示するとよさそう？それか、またのご利用おまちしております的なやつかなぁ"),
                IconButton(
                  icon: Icon(Icons.account_circle),
                  onPressed: () {
                    _showSignInScreen(context);
                  },
                )
              ],
            ));
      }
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppConfig.kTheme.primaryColor,
          title: Text(Strings.of(context).roomTitle),
          elevation: 4.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.group_add),
              tooltip: Strings.of(context).joinRoom,
              onPressed: () => _onPressJoinRoomButton(),
            ),
          ],
        ),
        body: body(),
      );
    }

//    return ModalProgressHUD(child: screen(), inAsyncCall: _isProgress);

    return screen();
  }

  void _showSignInScreen(BuildContext context) async {
    User user = await widget._appNavigator.showSingInScreen(context);
    setState(() {
      widget.user = user;
    });
  }

  Widget _getSlidableWithLists(BuildContext context, Room room) {
    return Slidable(
      direction: Axis.horizontal,
      delegate: SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: _getRoomListItemWidget(context, room),
      actions: <Widget>[
        IconSlideAction(
          caption: Strings.of(context).qrCode,
          color: Colors.blue,
          icon: FontAwesomeIcons.qrcode,
          onTap: () => _onPressDisplayQrCodeButton(room),
        ),
        IconSlideAction(
            caption: Strings.of(context).notification,
            color: Colors.indigo,
            icon: room.isNotify ? Icons.volume_up : Icons.volume_off,
            onTap: (() {
              room.isNotify = !room.isNotify;
              widget.viewModel
                  .updatePushNotificationSubscription(room, widget.user);
            })),
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: Strings.of(context).leaveTheRoom,
          color: Colors.red,
          icon: Icons.arrow_back,
          onTap: () => _onTapLeaveRoomButton(room),
        ),
      ],
    );
  }

  void _onPressDisplayQrCodeButton(Room room) async {
    await widget._appNavigator.showDisplayQrCodeScreen(context, room.id);
  }

  void _onTapLeaveRoomButton(Room room) async {
    bool isOk = await widget._appNavigator.showDialogMessage(context,
        message: Strings.of(context).checkLeaveRoom);
    if (!isOk) {
      return;
    }

    try {
      await widget.viewModel.leaveRoom(room, widget.user);
    } catch (error) {
      ExceptionUtil.showErrorMessage(widget._appNavigator, context, error);
    }
  }

  Widget _getRoomListItemWidget(BuildContext context, Room room) {
    String getLastMessage() {
      if (room.lastMessage.content != null) {
        if (widget.user.blockUserList.hasBlockUser(room.lastMessage.roomUser)) {
          return Strings.of(context).blockedUserMessage;
        }

        return room.lastMessage.content;
      }
      if (room.lastMessage.roomUser != null &&
          room.lastMessage.roomUser.isMine != null &&
          room.lastMessage.roomUser.isMine) {
        return Strings.of(context).sentImage;
      }
      return Strings.of(context).imageHasArrived;
    }

    Widget getLastMessageWidget() {
      if (room.lastMessage != null) {
        return Text(
          getLastMessage(),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        );
      }
      return null;
    }

    return ListTile(
      leading:
          ImageUtils.circle(room.photoUrl, text: room.name, fontSize: 15.0),
      title: Text(room.name),
      subtitle: getLastMessageWidget(),
      // isDisplayの使い方参考
      //trailing: widget.user.paidPlan.isDisplayAd ? Text('Ad') : Text('no'),
      onTap: () {
        _showRoomDetailPage(context, room, widget.user);
      },
    );
  }

  void _showRoomDetailPage(BuildContext context, Room room, User user) {
    widget._appNavigator.showRoomDetailPage(context, room, user);
  }

  void _onPressJoinRoomButton() async {
    try {
      String roomId = await widget.joinRoomReader.scan(context, widget.user);
      if (roomId != null) {
        AnalyticsHelper.instance.sendJoinRoom(roomId);
      }
    } catch (error) {
      ExceptionUtil.showErrorMessageIfNeeded(
          widget._appNavigator, context, error);
    }
  }

  void _setupPushNotification() async {
    StreamBuilder<Push>(
      stream: widget.viewModel.watchPushNotification(),
      builder: (context, snapshot) {
        switch (snapshot.data.pushMessage.pushMessageType) {
          case PushMessageType.Message:
            // アプリ起動中にプッシュが届くとダイアログが表示され、うざいため非表示にする。
            break;
          case PushMessageType.Launch:
            _navigateToRoom(snapshot.data.room);
            break;
          case PushMessageType.Resume:
            _navigateToRoom(snapshot.data.room);
            break;
        }
        return null;
      },
    );

    await widget.viewModel.requestNotificationPermissions();
    await widget.viewModel.registerToken(widget.user);
  }

  void _navigateToRoom(Room room) {
    widget._appNavigator.showRoomDetailPage(context, room, widget.user);
  }
}
