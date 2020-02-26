import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/usecase/AdsUseCase.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/BaseScreenState.dart';
import 'package:instantonnection/presentation/common/ImageUtils.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';

class RoomSettingScreen extends StatefulWidget implements Screen {
  final Room room;

  final User user;

  final AppNavigator appNavigator;

  final AdsUseCase adsUseCase;

  const RoomSettingScreen(
      {Key key, this.room, this.user, this.appNavigator, this.adsUseCase})
      : super(key: key);

  @override
  _RoomSettingScreenState createState() => _RoomSettingScreenState();

  @override
  String get name => "/rooms/${room.id}/settings";
}

class _RoomSettingScreenState extends BaseScreenState<RoomSettingScreen> {
  Room room;

  @override
  void initState() {
    super.initState();
    widget.adsUseCase.loadInterstitial(widget.user);
    room = widget.room;
  }

  @override
  void dispose() {
    widget.adsUseCase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget roomImageWidget = Container(
        padding: EdgeInsets.all(16.0),
        child: ImageUtils.circle(room.photoUrl,
            radius: 50.0, text: room.name, fontSize: 30.0));

    Widget body = Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            roomImageWidget,
            Container(
              child: Text(room.name),
            )
          ],
        )
      ],
    ));

    Widget editRoomButton = IconButton(
      icon: Icon(Icons.edit),
      tooltip: Strings.of(context).editRoom,
      onPressed: () {
        _showRandomInterstitialAd();
        _showEditRoomScreen();
      },
    );

    List<Widget> actions = List<Widget>()..add(editRoomButton);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            actions: actions,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(Strings.of(context).roomSettingsTitle),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate(<Widget>[
            AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.dark, child: body),
          ])),
        ],
      ),
    );
  }

  Future _showEditRoomScreen() async {
    Room result = await widget.appNavigator
        .showEditRoomScreen(context: context, room: room, user: widget.user);
    if (result != null) {
      debugPrint(result.toString());
      setState(() {
        room = result;
      });
    }
  }

  void _showRandomInterstitialAd() {
    widget.adsUseCase.showInterstitial(widget.user).then((showed) {
      if (!showed) {
        return;
      }
      widget.adsUseCase.loadInterstitial(widget.user);
    });
  }
}
