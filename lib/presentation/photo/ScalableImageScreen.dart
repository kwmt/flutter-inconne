import 'dart:io';

import 'package:flutter/material.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/analytics/AnalyticsHelper.dart';
import 'package:photo_view/photo_view.dart';

class ScalableImageScreen extends StatelessWidget implements Screen {
  final List<String> imageUrls;

  final int position;

  ScalableImageScreen({Key key, this.imageUrls, this.position})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.instance.sendCurrentScreen(this);
    return DefaultTabController(
      initialIndex: position,
      length: imageUrls.length,
      child: _PageSelector(imageUrls: imageUrls, position: position),
    );
  }

  @override
  String get name => "/preview/scalable";
}

class _PageSelector extends StatelessWidget {
  const _PageSelector({this.imageUrls, this.position});

  final List<String> imageUrls;
  final int position;

  void _handleArrowButtonPress(BuildContext context, int delta) {
    final TabController controller = DefaultTabController.of(context);
    if (!controller.indexIsChanging)
      controller
          .animateTo((controller.index + delta).clamp(0, imageUrls.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final TabController controller = DefaultTabController.of(context);
    final Color color = Theme.of(context).accentColor;

    Widget previewWidget = Scaffold(
      appBar: AppBar(
        title: Text(Strings.of(context).previewTitle),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: TabBarView(
                children: imageUrls.map((String imageUrl) {
              return Container(
                child: Center(
                  child: PhotoView(
                    imageProvider: NetworkImage(imageUrl),
                    minScale: PhotoViewComputedScale.contained * 1.0,
                    maxScale: 2.0,
                  ),
                ),
              );
            }).toList()),
          ),
        ],
      ),
    );

    UniqueKey key = UniqueKey();
    // FIXME:
    // https://gitlab.com/kwmt/instantonnection/issues/51
    return Dismissible(
            key: key,
            direction: DismissDirection.vertical,
            onDismissed: (direction) {
              Navigator.pop(context);
            },
            child: previewWidget,
          );
  }
}
