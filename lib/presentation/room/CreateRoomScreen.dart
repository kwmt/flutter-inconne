import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/usecase/CreateNewRoomUseCase.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/BaseScreenState.dart';
import 'package:instantonnection/presentation/common/ExceptionUtil.dart';
import 'package:instantonnection/presentation/common/ImageUtils.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

// ignore: must_be_immutable
class CreateRoomScreen extends StatefulWidget implements Screen {
  final CreateNewRoomUseCase createNewRoomUseCase;

  /// だれがRoomを作るのか
  User user;

  /// 何という名前や画像のRoomを作るか
  final Room room;

  final AppNavigator _navigator;

  CreateRoomScreen(this.user, this.createNewRoomUseCase, this._navigator,
      {this.room});

  @override
  _CreateRoomScreenState createState() => _CreateRoomScreenState();

  @override
  String get name => "/rooms/new";
}

class _CreateRoomScreenState extends BaseScreenState<CreateRoomScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Room _editingRoom;

  File _imageFile;

  bool _creating = false;

  TextEditingController _texEditingController;

  /// 入力中のRoom名
  String _inputtingRoomName;

  @override
  void initState() {
    super.initState();
    _texEditingController = TextEditingController();
    _texEditingController.addListener(_textEditListener);
  }

  @override
  void dispose() {
    _texEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget roomImageWidget = GestureDetector(
      child: Stack(
        alignment: const Alignment(0.6, 0.6),
        children: [
          ImageUtils.circleImageProvider(_previewImage(_imageFile),
              radius: 100.0, text: _inputtingRoomName),
          Icon(Icons.camera_alt),
        ],
      ),
      onTap: () {
        _onTapRoomImage(context);
      },
    );

    Widget createRoomNameWidget = Container(
      padding: EdgeInsets.only(top: 16.0),
      child: TextFormField(
        controller: _texEditingController,
        maxLength: 20,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(2.0))),
          hintText: Strings.of(context).inputRoomName,
        ),
        onSaved: (String name) {
          debugPrint(name);
          if (name.isEmpty) {
            _editingRoom = null;
            return;
          }
          _editingRoom = Room(name: name);
        },
      ),
    );

    _createRoom() async {
      setState(() {
        _creating = true;
      });

      try {
        bool success = await widget.createNewRoomUseCase
            .execute(_editingRoom, widget.user, imageFile: _imageFile);
        setState(() {
          _creating = false;
        });

        if (success) {
          Navigator.of(context).pop<Room>(_editingRoom);
        }
      } catch (error) {
        setState(() {
          _creating = false;
        });
        bool shouldNavigate = await ExceptionUtil.showErrorMessage(
            widget._navigator, context, error);
        if (shouldNavigate) {
          User user =
              await widget._navigator.showPurchaseScreen(context, widget.user);
          setState(() {
            widget.user = user;
          });
        }
      }
    }

    Widget body = SingleChildScrollView(
      child: Form(
          key: _formKey,
          child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: roomImageWidget,
                  ),
                  createRoomNameWidget,
                ],
              ))),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.of(context).createRoomTitle),
        elevation: 4.0,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              _formKey.currentState.save();
              if (_editingRoom == null) {
                return;
              }
              try {
                _createRoom();
              } catch (e) {
                debugPrint(e);
              }
            },
            child: Text(
              Strings.of(context).create,
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: ModalProgressHUD(child: body, inAsyncCall: _creating),
    );
  }

  void _onTapRoomImage(BuildContext context) {
    widget._navigator.showCameraSelector(context, () {
      _onImageButtonPressed(context, ImageSource.gallery);
      Navigator.of(context).pop();
    }, () {
      _onImageButtonPressed(context, ImageSource.camera);
      Navigator.of(context).pop();
    });
  }

  void _onImageButtonPressed(BuildContext context, ImageSource source) async {
    File selectedImageFile = await ImagePicker.pickImage(source: source);
    if (selectedImageFile == null) {
      return;
    }
    setState(() {
      _imageFile = selectedImageFile;
      _inputtingRoomName = null;
    });
  }

  ImageProvider _previewImage(File file) {
    return file != null ? FileImage(file) : null;
  }

  void _textEditListener() {
    if (_texEditingController.text.isEmpty || _imageFile != null) {
      setState(() {
        _inputtingRoomName = null;
      });
      return;
    }

    setState(() {
      _inputtingRoomName = _texEditingController.text;
    });
  }
}
