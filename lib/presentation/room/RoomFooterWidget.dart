import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instantonnection/domain/model/Message.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/UploadTask.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/usecase/CreateNewMessageUseCase.dart';
import 'package:instantonnection/domain/usecase/GetMessageUseCase.dart';
import 'package:instantonnection/domain/usecase/SaveMessageUseCase.dart';
import 'package:instantonnection/domain/usecase/UploadImageUseCase.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/ExceptionUtil.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';

class RoomFooterWidget extends StatefulWidget {
  final Room room;
  User user;

  final CreateNewMessageUseCase createNewMessageUseCase;
  final UploadImageUseCase uploadImageUseCase;
  final SaveMessageUseCase saveMessageUseCase;
  final GetMessageUseCase getMessageUseCase;
  final AppNavigator appNavigator;

  /// メッセージ送信完了時のコールバック
  final VoidCallback onMessageSendCompletionCallback;

  /// 画像アップロード直前のコールバック
  /// アップロード中を表示するためにリストに追加するために使用する
  final VoidCallback onPreUploadImageCallback;

  /// アップロード中を表示するためにリストに追加したリストアイテムを削除するために使用する
  final VoidCallback onPostUploadImageCallback;

  final _RoomFooterWidgetState _roomFooterWidget = _RoomFooterWidgetState();

  RoomFooterWidget(
      this.room,
      this.user,
      this.createNewMessageUseCase,
      this.uploadImageUseCase,
      this.saveMessageUseCase,
      this.getMessageUseCase,
      this.appNavigator,
      {this.onMessageSendCompletionCallback,
      this.onPreUploadImageCallback,
      this.onPostUploadImageCallback});

  @override
  _RoomFooterWidgetState createState() => _roomFooterWidget;

  void requestFocus() {
    _roomFooterWidget.requestFocus();
  }
}

class _RoomFooterWidgetState extends State<RoomFooterWidget>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  TextEditingController _texEditingController;

  bool _textEditIsEmpty = true;
  int _maxLines;

  RoomUser _updatedUser;

  FocusNode _focusNodeOther;

  GlobalKey _leftToolsWidgetKey = GlobalKey();
  GlobalKey _textFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _texEditingController = TextEditingController();
    _updatedUser = widget.room.myRoomUser;
    setMessageFromTemporary();

    controller = AnimationController(
        duration: const Duration(milliseconds: 0), vsync: this);
    // 96はiPhone Xで測ったときの値
    animation = Tween(begin: 0.0, end: 96.0).animate(controller);
    _texEditingController.addListener(_textEditListener);
  }

  @override
  void dispose() async {
    _focusNodeOther?.dispose();
    saveMessageToStorage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildFooter(),
    );
  }

  void setMessageFromTemporary() {
    widget.getMessageUseCase.execute(widget.room.id).then((message) {
      setState(() {
        _texEditingController.text = message;
      });
    });
  }

  Future<void> saveMessageToStorage() async {
    await _createTextMessage().then((message) {
      widget.saveMessageUseCase.execute(message, widget.room.id);
    });
  }

  void _textEditListener() {
    setState(() {
      // FIXME: Textfieldに改行が2つ以上入っていたら、3行以上になるので、3行までに止めたい。
      _maxLines =
          '\n'.allMatches(_texEditingController.text).length >= 2 ? 3 : null;
      _textEditIsEmpty = _texEditingController.text.isEmpty;

      if (_focusNodeOther == null) {
        _focusNodeOther = FocusNode();
      }

//      print("left: ${_leftToolsWidgetKey.currentContext.size}");
//      print("right: ${_textFieldKey.currentContext.size}");

      // leftToolsWidgetのWidthが確定した値を設定したいのだが、ここでanimationに再代入したらダメだった・・・
//      animation =
//          Tween(begin: 0.0, end: _leftToolsWidgetKey.currentContext.size.width)
//              .animate(controller);

      _animateToolWidgetsWidth();
    });
  }

  Widget _buildFooter() {
    return Container(
        padding: EdgeInsets.all(8.0),
        color: Colors.black12,
        child: Row(
            // _focusNodeOther が nullならRoomを開いたときを意味し、カメラありのNormalFooterにする。
            // TextFieldをタップした時かfooter以外(list部分)をタップしたとき、_focusNodeOtherを初期化する。
            // TextFieldをタップしたとき、_focusNodeOtherはfocusを持っていないので入力中のFooterWidgetに切り替える。
            // List部分をタップしたとき、_focusNodeOtherはfocusを持つことになるので、カメラありのFooterWidgetに切り替える。
            children: _createNormalFooterWidgets()));
  }

  List<Widget> _createNormalFooterWidgets() => [
        _footerLeftTools(),
        _messageTextField(),
        _sendButton(),
      ];

  List<Widget> _createInputtingTextFooterWidgets() => [
        // _changeNormalFooterWidgetButton(),
        _messageTextField(),
        _sendButton(),
      ];

  Widget _footerLeftTools() {
    _animateToolWidgetsWidth();

    return SizedBox(
      key: _leftToolsWidgetKey,
      width: animation.value,
      child: Container(
        child: Row(
          children: <Widget>[
            _photoLibraryButton(),
            _cameraButton(),
          ],
        ),
      ),
    );
  }

  void _animateToolWidgetsWidth() {
    if (_focusNodeOther == null) {
      controller.forward();
      return;
    }
    if (_focusNodeOther.hasFocus) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  // 通常のFooterに変更するボタン
  // TODO: 未実装
  Widget _changeNormalFooterWidgetButton() {
    return Container(
      child: IconButton(
          icon: Icon(Icons.forward),
          onPressed: () {
            _onImageButtonPressed(ImageSource.camera);
          }),
    );
  }

  Widget _messageTextField() {
    return Expanded(
      child: SizedBox(
        key: _textFieldKey,
        child: Container(
          padding: EdgeInsets.only(left: 8.0),
          child: TextFormField(
            controller: _texEditingController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: Strings.of(context).enterAMessage,
            ),
            maxLines: _maxLines,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),
        ),
      ),
    );
  }

  Widget _cameraButton() {
    return Container(
      child: IconButton(
          icon: Icon(Icons.photo_camera),
          onPressed: () {
            _onImageButtonPressed(ImageSource.camera);
          }),
    );
  }

  Widget _photoLibraryButton() {
    return Container(
      child: IconButton(
          icon: Icon(Icons.photo_library),
          onPressed: () {
            _onImageButtonPressed(ImageSource.gallery);
          }),
    );
  }

  Widget _sendButton() => Container(
      child: IconButton(
          icon: Icon(Icons.send),
          color: Colors.blueAccent,
          onPressed: _textEditIsEmpty
              ? null
              : () {
                  _createTextMessage().then((message) {
                    if (message.content?.isEmpty ?? true) {
                      // 空文字の場合は送信しない
                      return;
                    }
                    // _texEditingController.clear()のみだと、日本語入力時に確定させずに送信ボタンを押すと、clear時にクラッシュしていた。
                    // まだ理由はわかっていないが、clearComposingを先に呼ぶとクラッシュしなかったのでこのようにしている。
                    _texEditingController
                      ..clearComposing()
                      ..clear();
                    sendMessage(message).then((success) {
                      widget.onMessageSendCompletionCallback();
                    }).catchError((e) {
                      debugPrint(e.toString());
                    });
                  });
                }));

  Future<Message> _createTextMessage() {
    return Future.value(
        Message.create(_texEditingController.text, _updatedUser));
  }

  Future<bool> sendMessage(Message message) async {
//    debugPrint(text);
    try {
      await widget.createNewMessageUseCase.execute(widget.room, message);
      return Future.value(true);
    } catch (e) {
      debugPrint(e.toString());
      return Future.value(false);
    }
  }

  void _onImageButtonPressed(ImageSource source) async {
    File selectedImageFile = await ImagePicker.pickImage(source: source);
    if (selectedImageFile == null) {
      return;
    }

    File file = await widget.appNavigator
        .showPreviewPhotoScreen(context, selectedImageFile);
    if (file == null) {
      return;
    }

    widget.onPreUploadImageCallback();

    try {
      UploadTask uploadTask = await widget.uploadImageUseCase
          .message(file, widget.room, widget.user);
      _sendMessageImage(uploadTask);
    } catch (error) {
      widget.onPostUploadImageCallback();

      bool shouldNavigate = await ExceptionUtil.showErrorMessage(
          widget.appNavigator, context, error);
      if (shouldNavigate) {
        User user =
            await widget.appNavigator.showPurchaseScreen(context, widget.user);
        setState(() {
          widget.user = user;
        });
      }
    }
  }

  Future<Null> _sendMessageImage(UploadTask task) async {
    final String url = await task.ref.getDownloadURL();
    Message message = Message.createImage(url, _updatedUser);
    sendMessage(message).then((success) {
      widget.onMessageSendCompletionCallback();
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  void requestFocus() {
    if (_focusNodeOther == null) {
      _focusNodeOther = FocusNode();
    }
    FocusScope.of(context).requestFocus(_focusNodeOther);
  }
}
