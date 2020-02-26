import 'dart:io';

import 'package:flutter/material.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/BaseScreenState.dart';
import 'package:instantonnection/presentation/common/Screen.dart';

class PreviewPhotoScreen extends StatefulWidget implements Screen {
  final File _imageFile;

  const PreviewPhotoScreen(this._imageFile);

  @override
  _PreviewPhotoScreenState createState() => _PreviewPhotoScreenState();

  @override
  String get name => "/preview";
}

class _PreviewPhotoScreenState extends BaseScreenState<PreviewPhotoScreen> {
  Widget _previewImage() {
    return widget._imageFile != null ? Image.file(widget._imageFile) : Text("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Strings.of(context).previewTitle),
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: _previewImage(),
            ),
            Container(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        FloatingActionButton(
                          onPressed: () {
                            Navigator.pop<File>(context, null);
                          },
                          heroTag: Strings.of(context).cancel,
                          tooltip: Strings.of(context).cancelToolTip,
                          child: const Icon(Icons.cancel),
                        ),
                        FloatingActionButton(
                          onPressed: () {
                            Navigator.pop<File>(context, widget._imageFile);
                          },
                          heroTag: Strings.of(context).sendImage,
                          tooltip: Strings.of(context).sendImageToolTip,
                          child: const Icon(Icons.send),
                        ),
                      ]),
                ))
          ],
        ));
  }
}
