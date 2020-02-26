import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/UploadTask.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/usecase/UpdateRoomUseCase.dart';
import 'package:instantonnection/domain/usecase/UploadImageUseCase.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/BaseScreenState.dart';
import 'package:instantonnection/presentation/common/ImageUtils.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/analytics/AnalyticsHelper.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class EditRoomScreen extends StatefulWidget implements Screen {
  final Room room;
  final User user;
  final UpdateRoomUseCase updateRoomUseCase;
  final UploadImageUseCase uploadImageUseCase;
  final AppNavigator appNavigator;

  const EditRoomScreen(
      {Key key,
      this.room,
      this.user,
      this.updateRoomUseCase,
      this.uploadImageUseCase,
      this.appNavigator})
      : assert(room != null),
        assert(user != null),
        super(key: key);

  @override
  _EditRoomScreenState createState() => _EditRoomScreenState();

  @override
  String get name => "/rooms/${room.id}/edit";
}

class _EditRoomScreenState extends BaseScreenState<EditRoomScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Room _editingRoom;

  TextEditingController _controller;

  File _imageFile;

  bool _updating = false;

  @override
  void initState() {
    super.initState();
    this._editingRoom = widget.room;

    _controller = TextEditingController(text: _editingRoom.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget roomImageWidget = Center(
      child: Builder(
        builder: (context) => GestureDetector(
              child: Stack(
                alignment: const Alignment(0.6, 0.6),
                children: [
                  _imageFile != null
                      ? ImageUtils.circleImageProvider(FileImage(_imageFile),
                          radius: 50.0, fontSize: 30.0)
                      : ImageUtils.circle(widget.room.photoUrl,
                          radius: 50.0, text: widget.room.name, fontSize: 30.0),
                  Icon(Icons.camera_alt),
                ],
              ),
              onTap: () {
                _onTapRoomImage(context);
              },
            ),
      ),
    );

    Future<bool> _willPopCallback() async {
      if (_controller.text != widget.room.name || _imageFile != null) {
        return widget.appNavigator.showDialogMessage(context,
                title: Strings.of(context).unsavedChanges,
                message: Strings.of(context).unsavedChangesMessage) ??
            false;
      }
      // trueで戻る。falseで戻らない
      return true; // return true if the route to be popped
    }

    Widget body = WillPopScope(
      onWillPop: _willPopCallback,
      child: Form(
          key: _formKey,
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  roomImageWidget,
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      onSaved: (String name) {
                        _editingRoom.name = name;
                      },
                      validator: (value) => _validateRoomName(context, value),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.of(context).editRoomTitle),
        elevation: 4.0,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              _handleUpdateRoomName(context);
            },
            child: Text(
              Strings.of(context).save,
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: ModalProgressHUD(child: body, inAsyncCall: _updating),
    );
  }

  void _handleUpdateRoomName(BuildContext context) {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      widget.appNavigator.showDialogMessage(context,
          message: Strings.of(context).roomNameIsRequired);
    } else {
      form.save();
      _updateRoom();
    }
  }

  String _validateRoomName(BuildContext context, String value) {
    if (value.isEmpty) {
      return Strings.of(context).roomNameIsRequired;
    }
    return null;
  }

  void _onTapRoomImage(BuildContext context) {
    widget.appNavigator.showCameraSelector(context, () {
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
    });
  }

  void _updateRoom() async {
    setState(() {
      _updating = true;
    });

    Future _updateRoom() async {
      await Future.wait([
        widget.updateRoomUseCase.execute(_editingRoom),
      ]);
      setState(() {
        _updating = false;
      });

      AnalyticsHelper.instance.sendChangeRoom();
      Navigator.of(context).pop<Room>(_editingRoom);
    }

    if (_imageFile != null) {
      UploadTask uploadTask = await widget.uploadImageUseCase
          .room(_imageFile, _editingRoom, widget.user);
      _editingRoom.photoUrl = await uploadTask.ref.getDownloadURL();
      _updateRoom();
      return;
    }
    await _updateRoom();
  }
}
