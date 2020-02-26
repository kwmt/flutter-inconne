import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instantonnection/domain/model/Message.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/usecase/FetchChatListOfRoomUseCase.dart';
import 'package:instantonnection/domain/usecase/LeaveRoomUseCase.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/BaseScreenState.dart';
import 'package:instantonnection/presentation/common/ExceptionUtil.dart';
import 'package:instantonnection/presentation/common/ImageUtils.dart';
import 'package:instantonnection/presentation/common/LinkTextSpan.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';
import 'package:instantonnection/presentation/room/RoomFooterWidget.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

// ignore: must_be_immutable
class RoomScreen extends StatefulWidget implements Screen {
  final Room room;
  User user;
  final FetchChatListOfRoomUseCase fetchChatListOfRoomUseCase;
  final LeaveRoomUseCase _leaveRoomUseCase;
  final AppNavigator navigator;

  RoomScreen(
    this.room,
    this.user,
    this.fetchChatListOfRoomUseCase,
    this._leaveRoomUseCase,
    this.navigator,
  );

  @override
  _RoomScreenState createState() => _RoomScreenState();

  @override
  String get name => "/rooms/${room.id}";
}

class _RoomScreenState extends BaseScreenState<RoomScreen> {
  List<Message> messages = List();

  StreamSubscription _watchChatRoom;

  ScrollController _scrollController;

  RoomUser _updatedUser;

  bool _isProgress = false;

  RoomFooterWidget _roomFooterWidget;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _updatedUser = widget.room.myRoomUser;

    _isProgress = true;
    _watchChatRoom = widget.fetchChatListOfRoomUseCase
        .watch(widget.room, widget.user, (List<Message> messages) {
      setState(() {
        _isProgress = false;
        this.messages.clear();
        this.messages.addAll(messages);
      });
    });

    _scrollController.addListener(_scrollListener);

    _roomFooterWidget =
        Injector.getInjector().get<RoomFooterWidget>(additionalParameters: {
      "room": widget.room,
      "user": widget.user,
      "onMessageSendCompletionCallback": _scrollToBottom,
      "onPreUploadImageCallback": _addUploadingMessage,
      "onPostUploadImageCallback": _removeUploadingMessage
    });
  }

  void _scrollListener() {
    // 一番下← 0 ~ 1 → 一番上
    double heightRate =
        _scrollController.offset / _scrollController.position.maxScrollExtent;

    const threshold = 0.8;
    if (heightRate > threshold) {}

    if (heightRate < threshold - 0.05) {}
  }

  @override
  void dispose() async {
    super.dispose();
    if (_watchChatRoom != null) {
      _watchChatRoom.cancel();
    }

    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
  }

  Widget _buildListView() {
    List<Message> filteredMessages = messages;
    if (widget.user.blockUserList.blockUsers.length > 0) {
      widget.user.blockUserList.blockUsers.forEach((blockUser) {
        filteredMessages = filteredMessages.where((message) {
          return message.roomUser.userId != blockUser.userId;
        }).toList();
      });
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      itemCount: filteredMessages != null ? filteredMessages.length : 0,
      itemBuilder: (BuildContext context, int position) {
        return _buildMessageRow(context, filteredMessages[position], position);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.room.name),
          elevation: 4.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              tooltip: Strings.of(context).editRoom,
              onPressed: () => _onTapRoomSettingButton(),
            ),
            IconButton(
              icon: Icon(FontAwesomeIcons.qrcode),
              tooltip: Strings.of(context).displayRoomQrCode,
              onPressed: () => _onPressDisplayQrCodeButton(),
            ),
            PopupMenuButton<_RoomMenuType>(
              onSelected: _showMenuSelection,
              itemBuilder: (BuildContext context) =>
                  <PopupMenuItem<_RoomMenuType>>[
                    PopupMenuItem<_RoomMenuType>(
                      value: _RoomMenuType.REPORT,
                      child: Text(Strings.of(context).report),
                    ),
                    PopupMenuItem<_RoomMenuType>(
                      value: _RoomMenuType.LEAVE,
                      child: Text(
                        Strings.of(context).leaveTheRoom,
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  ],
            )
          ],
        ),
        body: ModalProgressHUD(
          child: _buildBody(),
          inAsyncCall: _isProgress,
        ),
      ),
    );
  }

  void _showMenuSelection(_RoomMenuType value) {
    switch (value) {
      case _RoomMenuType.REPORT:
        _onTapReportButton();
        break;
      case _RoomMenuType.LEAVE:
        _onTapLeaveRoomButton();
        break;
    }
  }

  void _showMessageMenuSelection(Message message) {
    _onTapReportButton(message: message);
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  Widget _buildBody() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [_buildMiddleSection(), _roomFooterWidget]);

  Widget _buildMiddleSection() => Expanded(
        child: Container(
            color: Colors.grey[200],
            child: GestureDetector(
              onTap: () {
                _roomFooterWidget.requestFocus();
              },
              child: _buildListView(),
            )),
      );

  void _addUploadingMessage() {
    Message message = Message.createImage(null, _updatedUser);
    // 画像のアップロード中を表示するため、一旦挿入
    this.messages.insert(0, message);
  }

  void _removeUploadingMessage() {
    // アップロードに失敗したら、アップロード中が残ったままになるので、削除
    setState(() {
      this.messages.removeAt(0);
    });
  }

  Widget _buildMessageRow(BuildContext context, Message message, int position) {
    return Container(
        margin: EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
              child: ImageUtils.circle(message.roomUser.photoUrl),
              onTap: () => _onTapUserIcon(
                  context, widget.user, message.roomUser, widget.room),
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(child: _listRightWidget(context, message, position)),
                  _buildPopUpMenu(context, message)
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildPopUpMenu(BuildContext context, Message message) {
    return PopupMenuButton<Message>(
      onSelected: _showMessageMenuSelection,
      itemBuilder: (BuildContext context) => <PopupMenuItem<Message>>[
            PopupMenuItem<Message>(
              value: message,
              child: Text(Strings.of(context).report),
            ),
          ],
    );
  }

  Widget _listRightWidget(
          BuildContext context, Message message, int position) =>
      Container(
        padding: EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: message.linkTextList != null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildNameWidget(message),
            message.linkTextList != null
                ? _buildMessageWidget(context, message)
                : _buildImageWidget(context, message, position),
          ],
        ),
      );

  Widget _buildNameWidget(Message message) {
    return Container(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(message.roomUser.name ?? Strings.of(context).unknownUser),
          Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Text(
                message.createdAtString,
                style: TextStyle(fontSize: 10.0),
              ))
        ],
      ),
    );
  }

  Widget _buildMessageWidget(BuildContext context, Message message) {
    final TextStyle aboutTextStyle = Theme.of(context).textTheme.body2;
    List<TextSpan> children = message.linkTextList.map((linkText) {
      // textがnullではなくurlがnullならリンクにしない。
      // textもurlもnullではない場合、urlに遷移するリンクにする。
      if (linkText.url == null) {
        return TextSpan(style: aboutTextStyle, text: linkText.text);
      }
      return LinkTextSpan(
          context: context, text: linkText.text, url: linkText.url);
    }).toList();

    return Container(
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 16.0),
          children: children,
        ),
      ),
    );
  }

  bool finishedSendingImageMessage = false;

  Widget _buildImageWidget(
      BuildContext context, Message message, int position) {
    return SizedBox(
        height: 180.0,
        child: Container(
            padding: EdgeInsets.only(top: 8.0, right: 8.0, bottom: 8.0),
            child: GestureDetector(
              onTap: () {
                _onTapImage(position);
              },
              child: message.downloadImageUrl != null
                  ? ImageUtils.roundedImage(message.downloadImageUrl.toString())
                  : Text(Strings.of(context).uploading),
            )));
  }

  void _onTapImage(int position) {
    // messagesからurlがあるメッセージだけに絞ったもの
    List<Message> filteredMessages = List();
    // Preview画面での選択位置
    int newPosition = position;

    int i = 0;
    messages.forEach((message) {
      if (message.downloadImageUrl.toString() != "null") {
        filteredMessages.add(message);
      } else {
        // 選択画像位置より前のMessageのdownloadImageUrlがnullならpositionは1つずれる
        // 選択画像位置より後のMessageにdownloadImageUrlがあった場合でも選択位置はずれないので、ずらさない。
        if (i <= position) {
          newPosition -= 1;
        }
      }
      i++;
    });

    List<String> imageUrls = filteredMessages
        .map((message) => message.downloadImageUrl.toString())
        .toList();

    widget.navigator.showScalableImageScreen(context, imageUrls, newPosition);
  }

  Future<void> _onPressDisplayQrCodeButton() async {
    await widget.navigator.showDisplayQrCodeScreen(context, widget.room.id);
  }

  Future<void> _onTapRoomSettingButton() async {
    await widget.navigator
        .showRoomSettingScreen(context, widget.room, widget.user);
  }

  void _onTapLeaveRoomButton() async {
    bool isOk = await widget.navigator.showDialogMessage(context,
        message: Strings.of(context).checkLeaveRoom);
    if (!isOk) {
      return;
    }

    try {
      await widget._leaveRoomUseCase.execute(widget.room, widget.user);
      Navigator.of(context).pop();
    } catch (error) {
      ExceptionUtil.showErrorMessage(widget.navigator, context, error);
    }
  }

  void _onTapReportButton({Message message}) async {
    widget.navigator
        .showReportScreen(context, widget.user, widget.room, message);
  }

  void _onTapUserIcon(
      BuildContext context, User user, RoomUser roomUser, Room room) async {
    User _user = await widget.navigator
        .showUserProfileScreen(context, user, roomUser, room);
    setState(() {
      widget.user = _user;
    });
  }
}

enum _RoomMenuType { REPORT, LEAVE }
