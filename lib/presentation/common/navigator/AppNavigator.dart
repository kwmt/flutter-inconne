import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:instantonnection/application/AppConfig.dart';
import 'package:instantonnection/domain/model/Message.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/MainScreen.dart';
import 'package:instantonnection/presentation/home/HomeSreen.dart';
import 'package:instantonnection/presentation/photo/PreviewPhotoScreen.dart';
import 'package:instantonnection/presentation/photo/ScalableImageScreen.dart';
import 'package:instantonnection/presentation/profile/BlockUserListScreen.dart';
import 'package:instantonnection/presentation/profile/EditThemeScreen.dart';
import 'package:instantonnection/presentation/profile/ProfileEditScreen.dart';
import 'package:instantonnection/presentation/profile/ProfileScreen.dart';
import 'package:instantonnection/presentation/purchase/PurchaseScreen.dart';
import 'package:instantonnection/presentation/report/ReportScreen.dart';
import 'package:instantonnection/presentation/room/CreateRoomScreen.dart';
import 'package:instantonnection/presentation/room/DisplayQrCodeScreen.dart';
import 'package:instantonnection/presentation/room/EditRoomScreen.dart';
import 'package:instantonnection/presentation/room/RoomScreen.dart';
import 'package:instantonnection/presentation/room/RoomSettingScreen.dart';
import 'package:instantonnection/presentation/signin/SigninScreen.dart';
import 'package:instantonnection/presentation/user/UserProfileScreen.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class AppNavigator {
  void showSnackBar(BuildContext context, String text);

  MaterialPageRoute<T> route<T extends dynamic>(
      String routePath, Widget destinationScreenWidget);

  Future<User> showSingInScreen(BuildContext context);

  Future<void> showRoomDetailPage(BuildContext context, Room room, User user);

  Future<Room> showCreateRoomScreen(
      {@required BuildContext context, @required User user, Room room});

  Future<Room> showEditRoomScreen(
      {@required BuildContext context, Room room, User user});

  Future<User> showProfileScreen(BuildContext context, User user);

  Future<dynamic> pushReplacementHomeScreen(BuildContext context, User user);

  Future<dynamic> pushReplacementMainScreen(BuildContext context);

  Future<User> showProfileEditScreen(
      BuildContext context, User user, List<Room> rooms);

  Future<User> showEditThemeScreen(BuildContext context, User user);

  Future<User> showBlockUserListScreen(BuildContext context, User user);

  Future<File> showPreviewPhotoScreen(BuildContext context, File imageFile);

  Future<void> showScalableImageScreen(
      BuildContext context, List<String> imageUrls, int position);

  Future<void> showDisplayQrCodeScreen(BuildContext context, String qrCodeData);

  Future<void> showRoomSettingScreen(
      BuildContext context, Room room, User user);

  Future<void> showCameraSelector(BuildContext context,
      VoidCallback onTapGallery, VoidCallback onTapCamera);

  /// ルームに参加するための手段を選択する画面を開く（カメラでQRコードを撮影するか、QRコード画像を開くか）
  Future<void> showJoinRoomSelector(
      BuildContext context, VoidCallback onTapCamera, VoidCallback onTapImage);

  /// 購入画面に遷移する
  Future<User> showPurchaseScreen(BuildContext context, User user);

  /// 広告非表示プラン購入画面に遷移する
  Future<User> showPurchaseProductScreen(BuildContext context, User user);

  /// 通報画面に遷移する
  Future<void> showReportScreen(BuildContext context, User user, Room room, Message message);

  /// 自分以外のユーザープロフィール画面に遷移する
  Future<User> showUserProfileScreen(
      BuildContext context, User user, RoomUser roomUser, Room room);

  Future<bool> showDialogMessage(BuildContext context,
      {String title, String message, bool isOkOnly});

  /// ブラウザに飛ばす
  Future<void> showBrowse(String url, {bool inApp});
}

class AppNavigatorImpl extends AppNavigator {
  @override
  void showSnackBar(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Future<User> showSingInScreen(BuildContext context) {
    return _showScreen(
        context, "/signin", Injector.getInjector().get<MySignInScreen>());
  }

  @override
  Future<void> showRoomDetailPage(BuildContext context, Room room, User user) {
    RoomScreen roomScreen = Injector.getInjector()
        .get<RoomScreen>(additionalParameters: {"room": room, "user": user});
    return _showScreen(context, roomScreen.name, roomScreen);
  }

  @override
  Future<void> showRoomSettingScreen(
      BuildContext context, Room room, User user) {
    RoomSettingScreen roomSettingScreen = Injector.getInjector()
        .get<RoomSettingScreen>(
            additionalParameters: {"room": room, "user": user});
    return _showScreen(context, roomSettingScreen.name, roomSettingScreen,
        modal: true);
  }

  @override
  Future<Room> showEditRoomScreen(
      {BuildContext context, Room room, User user}) {
    assert(room != null);
    assert(user != null);
    EditRoomScreen editRoomScreen = Injector.getInjector().get<EditRoomScreen>(
        additionalParameters: {"room": room, "user": user});
    return _showScreen(context, editRoomScreen.name, editRoomScreen);
  }

  @override
  Future<User> showProfileScreen(BuildContext context, User user) {
    ProfileScreen profileScreen = Injector.getInjector()
        .get<ProfileScreen>(additionalParameters: {"user": user});
    return _showScreen(context, profileScreen.name, profileScreen);
  }

  @override
  Future<User> showProfileEditScreen(
      BuildContext context, User user, List<Room> rooms) {
    ProfileEditScreen profileEditScreen = Injector.getInjector()
        .get<ProfileEditScreen>(
            additionalParameters: {"user": user, "rooms": rooms});
    return _showScreen(context, profileEditScreen.name, profileEditScreen,
        modal: true);
  }

  @override
  Future<User> showEditThemeScreen(BuildContext context, User user) {
    EditThemeScreen editThemeScreen = Injector.getInjector()
        .get<EditThemeScreen>(additionalParameters: {"user": user});
    return _showScreen(context, editThemeScreen.name, editThemeScreen);
  }

  @override
  Future<User> showBlockUserListScreen(BuildContext context, User user) {
    BlockUserListScreen editThemeScreen = Injector.getInjector()
        .get<BlockUserListScreen>(additionalParameters: {"user": user});
    return _showScreen(context, editThemeScreen.name, editThemeScreen);
  }

  /// 画面遷移する
  ///
  /// @param context
  /// @param routePath
  /// @param destinationScreenWidget
  /// @param modal iOSモーダルで画面遷移する場合はtrue
  Future<T> _showScreen<T extends dynamic>(
      BuildContext context, String routePath, Widget destinationScreenWidget,
      {bool modal = false}) {
    return Navigator.push(
      context,
      MaterialPageRoute<T>(
          settings: RouteSettings(name: routePath),
          builder: (BuildContext context) => Theme(
                data: AppConfig.kTheme
                    .copyWith(platform: Theme.of(context).platform),
                child: destinationScreenWidget,
              ),
          fullscreenDialog: modal),
    );
  }

  @override
  MaterialPageRoute<T> route<T extends dynamic>(
      String routePath, Widget destinationScreenWidget,
      {bool modal = false}) {
    return _FadeAnimationCustomRoute<T>(
        settings: RouteSettings(name: routePath),
        builder: (BuildContext context) => Theme(
              data: AppConfig.kTheme
                  .copyWith(platform: Theme.of(context).platform),
              child: destinationScreenWidget,
            ));
  }

  @override
  Future<dynamic> pushReplacementHomeScreen(BuildContext context, User user) {
    HomeScreen homeScreen = Injector.getInjector()
        .get<HomeScreen>(additionalParameters: {"user": user});
    MaterialPageRoute newRoute = route(homeScreen.name, homeScreen);
    return Navigator.of(context).pushReplacement(newRoute);
  }

  @override
  Future<dynamic> pushReplacementMainScreen(BuildContext context) {
    MainScreen mainScreen = Injector.getInjector().get<MainScreen>();
    MaterialPageRoute newRoute = route(mainScreen.name, mainScreen);
    return Navigator.of(context).pushReplacement(newRoute);
  }

  @override
  Future<Room> showCreateRoomScreen(
      {@required BuildContext context, User user, Room room}) {
    assert(context != null);
    CreateRoomScreen createRoomScreen = Injector.getInjector()
        .get<CreateRoomScreen>(
            additionalParameters: {"user": user, "room": room});
    return _showScreen(context, createRoomScreen.name, createRoomScreen,
        modal: true);
  }

  @override
  Future<File> showPreviewPhotoScreen(BuildContext context, File imageFile) {
    PreviewPhotoScreen previewPhotoScreen = Injector.getInjector()
        .get<PreviewPhotoScreen>(
            additionalParameters: {"imageFile": imageFile});
    return _showScreen(context, previewPhotoScreen.name, previewPhotoScreen);
  }

  @override
  Future<void> showScalableImageScreen(
      BuildContext context, List<String> imageUrls, int position) {
    ScalableImageScreen scalableImageScreen = Injector.getInjector()
        .get<ScalableImageScreen>(additionalParameters: {
      "imageUrls": imageUrls,
      "position": position
    });
    return _showScreen(context, scalableImageScreen.name, scalableImageScreen,
        modal: true);
  }

  @override
  Future<void> showDisplayQrCodeScreen(
      BuildContext context, String qrCodeData) {
    DisplayQrCodeScreen screen = Injector.getInjector()
        .get<DisplayQrCodeScreen>(
            additionalParameters: {"qrCodeData": qrCodeData});
    return _showScreen(context, screen.name, screen, modal: true);
  }

  @override
  Future<void> showCameraSelector(BuildContext context,
          VoidCallback onTapGallery, VoidCallback onTapCamera) =>
      showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text(Strings.of(context).gallery),
                    onTap: onTapGallery,
                  ),
                  ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text(Strings.of(context).camera),
                    onTap: onTapCamera,
                  ),
                ],
              ));

  @override
  Future<void> showJoinRoomSelector(BuildContext context,
          VoidCallback onTapCamera, VoidCallback onTapImage) =>
      showModalBottomSheet<void>(
          context: context,
          builder: (BuildContext context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text(Strings.of(context).takeQRCodeWithCamera),
                    onTap: () {
                      onTapCamera();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.photo_album),
                    title: Text(Strings.of(context).openQRCodeImage),
                    onTap: () {
                      onTapImage();
                    },
                  ),
                ],
              ));

  @override
  Future<User> showPurchaseScreen(BuildContext context, User user) {
    PurchaseScreen screen = Injector.getInjector().get<PurchaseScreen>(
        additionalParameters: {"user": user, "isForSubscription": true});
    return _showScreen<User>(context, screen.name, screen);
  }

  @override
  Future<User> showPurchaseProductScreen(BuildContext context, User user) {
    PurchaseScreen screen = Injector.getInjector().get<PurchaseScreen>(
        additionalParameters: {"user": user, "isForSubscription": false});
    return _showScreen<User>(context, screen.name, screen);
  }

  @override
  Future<void> showReportScreen(BuildContext context, User user, Room room, Message message) {
    ReportScreen reportScreen = Injector.getInjector()
        .get<ReportScreen>(additionalParameters: {"user": user, "room": room, "message": message});
    return _showScreen(context, reportScreen.name, reportScreen, modal: true);
  }

  @override
  Future<User> showUserProfileScreen(
      BuildContext context, User user, RoomUser roomUser, Room room) {
    UserProfileScreen userProfileScreen = Injector.getInjector()
        .get<UserProfileScreen>(
            additionalParameters: {"user": user, "roomUser": roomUser, "room": room});
    return _showScreen<User>(context, userProfileScreen.name, userProfileScreen);
  }

  @override
  Future<bool> showDialogMessage(BuildContext context,
      {String title, String message, bool isOkOnly = false}) {
    return showDialog<bool>(
      context: context,
      builder: (context) =>
          _buildDialog(context, title, message, isOkOnly: isOkOnly),
    );
  }

  Widget _buildDialog(BuildContext context, String title, String message,
      {bool isOkOnly = false}) {
    if (title == null && message == null) {
      throw ArgumentError("titleとmessageのどちらともnullです。どちらかは指定してください。");
    }

    List<Widget> actions = List();
    if (!isOkOnly) {
      actions.add(FlatButton(
        child: Text(Strings.of(context).cancel),
        onPressed: () {
          Navigator.pop(context, false);
        },
      ));
    }
    actions.add(FlatButton(
      child: Text(Strings.of(context).ok),
      onPressed: () {
        Navigator.pop(context, true);
      },
    ));

    return AlertDialog(
      title: title != null ? Text(title) : null,
      content: message != null ? Text(message) : null,
      actions: actions,
    );
  }

  @override
  Future<void> showBrowse(String url, {bool inApp = true}) {
    return launch(url, forceWebView: inApp);
  }
}

class _FadeAnimationCustomRoute<T> extends MaterialPageRoute<T> {
  _FadeAnimationCustomRoute(
      {WidgetBuilder builder,
      RouteSettings settings,
      bool fullscreenDialog = false})
      : super(
            builder: builder,
            settings: settings,
            fullscreenDialog: fullscreenDialog);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.isInitialRoute) return child;
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    return FadeTransition(opacity: animation, child: child);
  }
}
