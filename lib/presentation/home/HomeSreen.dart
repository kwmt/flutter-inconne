import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:instantonnection/application/AppConfig.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/presentation/common/BaseScreenState.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/analytics/AnalyticsHelper.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';
import 'package:instantonnection/presentation/profile/ProfileScreen.dart';
import 'package:instantonnection/presentation/room/RoomListScreen.dart';

class NavigationView {
  final Widget screenWidget;

  final BottomNavigationBarItem item;

  NavigationView({Widget icon, String itemTitle, Widget screenWidget})
      : item = BottomNavigationBarItem(icon: icon, title: Text(itemTitle)),
        screenWidget = screenWidget;
}

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget implements Screen {
  User _user;

  final AppNavigator _appNavigator;

  HomeScreen(this._user, this._appNavigator);

  @override
  _HomeScreenState createState() => _HomeScreenState();

  @override
  String get name => "/home";
}

class _HomeScreenState extends BaseScreenState<HomeScreen> {
  int _currentIndex = 0;

  final List<NavigationView> _children = [];

  ProfileScreen _profileScreen;

  RoomListScreen _roomListScreen;

  @override
  void initState() {
    super.initState();

    if (widget._user != null && widget._user.theme != null) {
      AppConfig.setAppTheme(widget._user.theme);
    }

  }

  @override
  Widget build(BuildContext context) {
    _children.clear();
    _profileScreen = Injector.getInjector()
        .get<ProfileScreen>(additionalParameters: {"user": widget._user});

    _roomListScreen = Injector.getInjector()
        .get<RoomListScreen>(additionalParameters: {"user": widget._user});

    List<NavigationView> widgets = [
      NavigationView(
          icon: Icon(Icons.home),
          itemTitle: 'Home',
          screenWidget: _roomListScreen),
      NavigationView(
          icon: Icon(Icons.add), itemTitle: 'Create Room', screenWidget: null),
      NavigationView(
          icon: Icon(Icons.person),
          itemTitle: 'Profile',
          screenWidget: _profileScreen),
    ];

    _children.addAll(widgets);



    return Scaffold(
        body: _children[_currentIndex].screenWidget,
        bottomNavigationBar: BottomNavigationBar(
            fixedColor: AppConfig.kTheme.primaryColor,
            onTap: onTabTapped,
            currentIndex: _currentIndex,
            items: _children
                .map((navigationView) => navigationView.item)
                .toList()));
  }

  void onTabTapped(int index) {
    AnalyticsHelper.instance
        .sendCurrentScreen((_children[_currentIndex].screenWidget as Screen));
    if (widget._user == null) {
      _showSignInScreen();
      return;
    }
    if (index == 1) {
      _showCreateRoomScreen();
      return;
    }

    // プロフィール編集した場合に、user情報を更新したいため、ここで参照している。
    // FIXME: [ProfileScreen]のFIXMEと同様に、ここもいい方法があれば直したい
    widget._user = _profileScreen.user;

    setState(() {
      _currentIndex = index;
    });
  }

  Future _showSignInScreen() async {
    User result = await widget._appNavigator.showSingInScreen(context);
    if (result != null) {
      setState(() {
        widget._user = result;
      });
    }
  }

  Future _showCreateRoomScreen() async {
    Room result = await widget._appNavigator
        .showCreateRoomScreen(context: context, user: widget._user);
    if (result != null) {
//      _roomListScreen.fetchRoomList();
    }
  }
}
