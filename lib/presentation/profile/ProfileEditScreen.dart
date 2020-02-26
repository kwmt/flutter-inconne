import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/UploadTask.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/usecase/UpdateUserProfileUseCase.dart';
import 'package:instantonnection/domain/usecase/UploadImageUseCase.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/BaseScreenState.dart';
import 'package:instantonnection/presentation/common/ExceptionUtil.dart';
import 'package:instantonnection/presentation/common/ImageUtils.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/analytics/AnalyticsHelper.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';
import 'package:instantonnection/presentation/profile/ProfileItemWidget.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ProfileEditScreen extends StatefulWidget implements Screen {
  final User _user;
  final List<Room> _rooms;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final UploadImageUseCase _uploadImageUseCase;
  final AppNavigator _appNavigator;

  ProfileEditScreen(
    this._user,
    this._rooms,
    this._updateUserProfileUseCase,
    this._uploadImageUseCase,
    this._appNavigator,
  );

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();

  @override
  String get name => "/profile/edit";
}

class _ProfileEditScreenState extends BaseScreenState<ProfileEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  User _editingUser;

  TextEditingController _textEditingController;

  File _imageFile;

  bool _updating = false;

  @override
  void initState() {
    super.initState();
    this._editingUser = widget._user.copy();
    this._textEditingController =
        TextEditingController(text: this._editingUser.name);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // https://stackoverflow.com/a/49356916
    Future<bool> _willPopCallback() async {
      if (_textEditingController.text != widget._user.name ||
          _imageFile != null) {
        return widget._appNavigator.showDialogMessage(context,
                title: Strings.of(context).unsavedChanges,
                message: Strings.of(context).unsavedChangesMessage) ??
            false;
      }
      // trueで戻る。falseで戻らない
      return true; // return true if the route to be popped
    }

    Widget body = WillPopScope(
      onWillPop: _willPopCallback,
      child: SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: GestureDetector(
                      child: Stack(
                          alignment: Alignment(0.6, 0.6),
                          children: <Widget>[
                            _imageFile != null
                                ? ImageUtils.circleImageProvider(
                                    FileImage(_imageFile),
                                    radius: 50.0)
                                : ImageUtils.circle(_editingUser.photoUrl,
                                    radius: 50.0),
                            Icon(Icons.camera_alt),
                          ]),
                      onTap: () {
                        _onTapProfileImage(context);
                      },
                    ),
                  ),
                ),
                _ProfileEditItemWidget(
                  title: Strings.of(context).name,
                  value: _editingUser.name,
                  textEditingController: _textEditingController,
                  onValueChanged: (name) {
                    _editingUser.name = name;
                  },
                ),
                ProfileItemWidget(
                  title: Strings.of(context).email,
                  value: _editingUser.email,
                ),
              ],
            ))),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.of(context).editProfile),
        elevation: 4.0,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              _handleUpdateUserName(context);
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

  void _handleUpdateUserName(BuildContext context) {
    FormState form = _formKey.currentState;
    if(!form.validate()) {
      widget._appNavigator.showDialogMessage(context,
          message: Strings.of(context).userNameIsRequired);
    } else {
      _formKey.currentState.save();
      _updateProfile();
    }
  }

  void _onTapProfileImage(BuildContext context) {
    widget._appNavigator.showCameraSelector(context, () {
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

  void _updateProfile() async {
    setState(() {
      _updating = true;
    });

    Future _updateProfile() async {
      try {
        await widget._updateUserProfileUseCase
            .execute(_editingUser, rooms: widget._rooms);

        AnalyticsHelper.instance.sendChangeUser();
        Navigator.of(context).pop(_editingUser);
      } catch (error) {
        ExceptionUtil.showErrorMessageIfNeeded(
            widget._appNavigator, context, error);
      } finally {
        setState(() {
          _updating = false;
        });
      }
    }

    if (_imageFile != null) {
      try {
        UploadTask uploadTask =
            await widget._uploadImageUseCase.profile(_imageFile, _editingUser);
        _editingUser.photoUrl = await uploadTask.ref.getDownloadURL();
        _updateProfile();
        return;
      } catch (error) {
        bool shouldNavigate = await ExceptionUtil.showErrorMessage(
            widget._appNavigator, context, error);
        if (shouldNavigate) {
          User user = await widget._appNavigator
              .showPurchaseScreen(context, _editingUser);
          setState(() {
            _editingUser = user;
          });
        }
      } finally {
        setState(() {
          _updating = false;
        });
      }
    }
    await _updateProfile();
  }
}

class _ProfileEditItemWidget extends StatefulWidget {
  _ProfileEditItemWidget(
      {this.title,
      this.value,
      this.textEditingController,
      this.onValueChanged});

  final String title;
  final String value;
  final TextEditingController textEditingController;
  final ValueChanged<String> onValueChanged;

  @override
  _ProfileEditItemWidgetState createState() => _ProfileEditItemWidgetState();
}

class _ProfileEditItemWidgetState extends State<_ProfileEditItemWidget> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: themeData.dividerColor))),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.subhead,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Container(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    width: 72.0,
                    child: Text(widget.title)),
                Expanded(
                  child: TextFormField(
                    controller: widget.textEditingController,
                    onSaved: (String name) {
                      widget.onValueChanged(name);
                    },
                    validator: (value) => _validateName(context, value),
                    maxLength: 80,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _validateName(BuildContext context, String value) {
    if (value.isEmpty) {
      return Strings.of(context).userNameIsRequired;
    }
    return null;
  }
}
