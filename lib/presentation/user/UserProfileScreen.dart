import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/repository/PushNotificationRepository.dart';
import 'package:instantonnection/domain/repository/RoomRepository.dart';
import 'package:instantonnection/domain/repository/UserRepository.dart';
import 'package:instantonnection/domain/usecase/UpdatePushNotificationSubscriptionUseCase.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/BaseScreenState.dart';
import 'package:instantonnection/presentation/common/ImageUtils.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';
import 'package:sliver_fab/sliver_fab.dart';

class UserProfileScreen extends StatefulWidget implements Screen {
  final UserProfileViewModel viewModel;
  final AppNavigator appNavigator;

  UserProfileScreen({this.viewModel, this.appNavigator});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();

  @override
  String get name => "/users/${viewModel.userId}";
}

const _kExpandedHeight = 120.0;

class _UserProfileScreenState extends BaseScreenState<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.init();
    if (mounted) {
      widget.viewModel.fetchUserProfile();
    }
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, widget.viewModel.user);
        return Future.value(false);
      },
      child: Scaffold(
        body: Builder(builder: (context) {
          return StreamBuilder<UserProfileViewModel>(
              initialData: widget.viewModel,
              stream: widget.viewModel.stream,
              builder: (BuildContext context,
                  AsyncSnapshot<UserProfileViewModel> snapshot) {
                List<Widget> _actions = List();
                if (!snapshot.data.isMine) {
                  _actions.add(_buildPopupMenuButtons(snapshot.data));
                }

                return SliverFab(
                  floatingWidget:
                      ImageUtils.circle(widget.viewModel.photoUrl, radius: 40),
                  floatingPosition: FloatingPosition(left: 16),
                  expandedHeight: _kExpandedHeight,
                  slivers: <Widget>[
                    SliverAppBar(
                      actions: _actions,
                      expandedHeight: _kExpandedHeight,
                      pinned: true,
//                  flexibleSpace: FlexibleSpaceBar(
//                    title: Text("SliverFab Example"),
//                    background: Image.asset(
//                      "img.jpg",
//                      fit: BoxFit.cover,
//                    ),
//                  ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        <Widget>[
                          AnnotatedRegion<SystemUiOverlayStyle>(
                              value: SystemUiOverlayStyle.dark,
                              child: _buildBody(context, snapshot.data))
                        ],
                      ),
                    )
                  ],
                );
              });
        }),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserProfileViewModel viewModel) {
    final bool hasBlockUser = viewModel.hasBlockUser;
    Widget unblockButton() {
      return Visibility(
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        visible: hasBlockUser,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            RaisedButton(
              child: Text(Strings.of(context).unblockUser),
              onPressed: _onTapUnblockUser,
            ),
          ],
        ),
      );
    }

    final Widget userProfileWidget = Container(
      padding: EdgeInsets.only(top: 10),
      child: Text(
        viewModel.roomUser.name,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );

    List<Widget> _listContents = List()
      ..add(unblockButton())
      ..add(userProfileWidget);

    return Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _listContents,
        ));
  }

  Widget _buildPopupMenuButtons(UserProfileViewModel viewModel) {
    List<String> menuTextList = [
      viewModel.hasBlockUser
          ? Strings.of(context).unblockUser
          : Strings.of(context).blockUser,
    ];
    List<PopupMenuItem<UserProfileAction>> menuItemList =
        UserProfileAction.values.map((enumValue) {
      return PopupMenuItem<UserProfileAction>(
          value: enumValue, child: Text(menuTextList[enumValue.index]));
    }).toList();

    return PopupMenuButton<UserProfileAction>(
        itemBuilder: (BuildContext context) => menuItemList,
        onSelected: (UserProfileAction action) {
          switch (action) {
            case UserProfileAction.BLOCK:
              _onTapBlockUser(context, viewModel);
              break;
          }
        });
  }

  void _onTapBlockUser(
      BuildContext context, UserProfileViewModel viewModel) async {
    if (viewModel.hasBlockUser) {
      viewModel.unblock();
      return;
    }

    bool isOk = await widget.appNavigator.showDialogMessage(context,
        title: "${Strings.of(context).blockUser} ${viewModel.name}",
        message: Strings.of(context).blockCheck,
        isOkOnly: false);
    if (isOk) {
      viewModel.block();
    }
  }

  void _onTapUnblockUser() {
    widget.viewModel.unblock();
  }
}

enum UserProfileAction { BLOCK }

class UserProfileActionText {
  UserProfileAction action;

  String text(BuildContext context) {
    switch (action) {
      case UserProfileAction.BLOCK:
        return Strings.of(context).blockUser;
      default:
        return Strings.of(context).blockUser;
    }
  }
}

class UserProfileViewModel {
  final User _user;
  final RoomUser _roomUser;
  final Room _room;
  final RoomRepository _roomRepository;
  final UserRepository _userRepository;
  final UpdatePushNotificationSubscriptionUseCase
      _updatePushNotificationSubscriptionUseCase;

  StreamController<UserProfileViewModel> _controller;

  Stream<UserProfileViewModel> get stream => _controller.stream;

  RoomUser get roomUser => _roomUser;

  UserProfileViewModel(
      this._user,
      this._roomUser,
      this._room,
      this._roomRepository,
      this._userRepository,
      this._updatePushNotificationSubscriptionUseCase);

  String get userId => _roomUser.userId;

  String get name => _roomUser.name;

  String get photoUrl => _roomUser.photoUrl;

  bool get hasBlockUser => _user.blockUserList.hasBlockUser(roomUser);

  User get user => _user;

  // RoomUserが自分かどうか
  bool get isMine => _user.uid == _roomUser.userId;

  void block() async {
    try {
      await Future.wait([
        _userRepository.addBlockUser(_user, _roomUser),
        _updatePushNotificationSubscriptionUseCase.subscribeBlockTopic()
      ]);
      _user.blockUserList.addRoomUser(_roomUser);
      _controller.add(this);
    } catch (error) {
      _controller.addError(error);
    }
  }

  void unblock() async {
    try {
      await Future.wait([
        _userRepository.removeBlockUser(_user, _roomUser),
        _updatePushNotificationSubscriptionUseCase.unsubscribeBlockTopic()
      ]);
      _user.blockUserList.removeRoomUser(_roomUser);
      _controller.add(this);
    } catch (error) {}
  }

  void fetchUserProfile() {
    _controller.add(this);
  }

  void init() {
    _controller = StreamController.broadcast();
  }

  void dispose() {
    _controller.close();
  }
}
