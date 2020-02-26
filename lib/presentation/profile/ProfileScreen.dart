import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instantonnection/application/AppConfig.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/usecase/AdsUseCase.dart';
import 'package:instantonnection/domain/usecase/FetchRoomListUseCase.dart';
import 'package:instantonnection/domain/usecase/LogoutUseCase.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/BaseScreenState.dart';
import 'package:instantonnection/presentation/common/ImageUtils.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';
import 'package:instantonnection/presentation/profile/ProfileItemWidget.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

enum ProfileAction {
  /// ログアウト
  logout,

  /// 利用規約
  termsOfService,

  /// プライバシーポリシー
  privacyPolicy,

  /// ヘルプ
  help,

  /// お問い合わせ
  contactUs,
}

class ProfileActionItem {
  ProfileAction profileAction;

  ProfileActionItem(this.profileAction);

  String text(BuildContext context) {
    switch (profileAction) {
      case ProfileAction.logout:
        return Strings.of(context).logout;
      case ProfileAction.termsOfService:
        return Strings.of(context).terms;
      case ProfileAction.privacyPolicy:
        return Strings.of(context).privacy;
      case ProfileAction.help:
        return Strings.of(context).help;
      case ProfileAction.contactUs:
        return Strings.of(context).contactUs;
      default:
        return "";
    }
  }
}

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget implements Screen {
  // なぜ mutableかつpublicにしているのか？
  // 理由: プロフィール編集（画像変更など）すると、ローカルのuserインスタンスのみしか更新されず、
  // ホームタブに切り替えプロフィール画面に戻ると、前の状態（前の画像）のままになってしまっていた。
  // そのため、親のWidget（[HomeScreen])にuser情報が変更されたことを通知したいため。
  // ここでは、タブの切替時にこのuserを参照して、HomeScreenのuser情報を更新している。
  // FIXME: ここをfinalにして、親に通知するいい方法があれば、変更したい
  User user;

  final LogoutUseCase _logoutUseCase;

  final FetchRoomListUseCase fetchRoomListUseCase;

  final AdsUseCase adsUseCase;

  final AppNavigator _appNavigator;

  ProfileScreen(this.user, this._logoutUseCase, this.fetchRoomListUseCase,
      this.adsUseCase, this._appNavigator);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();

  @override
  String get name => "/profile";
}

class _ProfileScreenState extends BaseScreenState<ProfileScreen> {
  final double _appBarHeight = 256.0;

  bool _isProgress = false;

  List<Room> _rooms = List();

  @override
  void initState() {
    super.initState();
    widget.adsUseCase.loadInterstitial(widget.user);
    _isProgress = true;
    widget.fetchRoomListUseCase.execute(widget.user).then((rooms) {
      setState(() {
        this._rooms = rooms;
        _isProgress = false;
      });
    });
  }

  @override
  void dispose() {
    widget.adsUseCase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget profileWidget = ProfileItemWidget(
      title: Strings.of(context).email,
      value: widget.user.email,
    );
    Widget paidPlanWidget = ProfileItemWidget(
      title: Strings.of(context).pricing,
      value: widget.user.paidPlan.title,
      onTap: _onTapPaidPlan,
    );

    List<Widget> bodyContents = [
      profileWidget,
      paidPlanWidget,
      _EditThemeItem(
          title: Strings.of(context).settingColorTheme, onTap: _onTapEditTheme),
      _EditThemeItem(
          title: Strings.of(context).blockedUserTitle,
          onTap: _onTapBlockedUsers)
    ];

    Widget body = Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: bodyContents,
    ));

    Widget editProfileButton = IconButton(
      icon: Icon(Icons.edit),
      tooltip: Strings.of(context).editProfile,
      onPressed: () {
        _showRandomInterstitialAd();
        _showProfileEditPage(context);
      },
    );

    Widget popupMenuButtons() {
      List<PopupMenuItem<ProfileAction>> menuItemList = ProfileAction.values
          .map((enumValue) => ProfileActionItem(enumValue))
          .map((item) {
            return PopupMenuItem<ProfileAction>(
                value: item.profileAction, child: Text(item.text(context)));
          })
          .where((enumValue) =>
              AppConfig.of(context).flavor == Flavor.DEVELOPMENT
                  ? true
                  : enumValue.value != ProfileAction.logout)
          .toList();

      return PopupMenuButton<ProfileAction>(
          itemBuilder: (BuildContext context) => menuItemList,
          onSelected: (ProfileAction action) {
            switch (action) {
              case ProfileAction.logout:
                _logout();
                break;
              case ProfileAction.termsOfService:
                _showBrowse(AppConfig.of(context).termsUrl);
                break;
              case ProfileAction.privacyPolicy:
                _showBrowse(AppConfig.of(context).privacyPolicyUrl);
                break;
              case ProfileAction.help:
                _showBrowse(AppConfig.of(context).helpUrl);
                break;
              case ProfileAction.contactUs:
                _showBrowse("https://goo.gl/forms/O8IiBFxmux6gNB0V2",
                    inApp: false);
                break;
            }
          });
    }

    List<Widget> actions = List<Widget>()
      ..add(editProfileButton)
      ..add(popupMenuButtons());

    Widget screen = WillPopScope(
      onWillPop: () {
//        Navigator.of(context).pop<User>(widget. widget.user);
      },
      child: Theme(
        data: AppConfig.kTheme,
        child: Scaffold(
          body: CustomScrollView(slivers: <Widget>[
            SliverAppBar(
              expandedHeight: _appBarHeight,
              pinned: true,
              elevation: 4.0,
              actions: actions,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.user.name),
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ImageUtils.cachedImage(widget.user.photoUrl.toString(),
                        fit: BoxFit.cover),
                    // This gradient ensures that the toolbar icons are distinct
                    // against the background image.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, -1.0),
                          end: Alignment(0.0, -0.4),
                          colors: <Color>[Color(0x60000000), Color(0x00000000)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate(<Widget>[
              AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle.dark, child: body),
            ]))
          ]),
        ),
      ),
    );
    return ModalProgressHUD(child: screen, inAsyncCall: _isProgress);
  }

  void _showRandomInterstitialAd() {
    widget.adsUseCase.showInterstitial(widget.user).then((showed) {
      if (!showed) {
        return;
      }
      widget.adsUseCase.loadInterstitial(widget.user);
    });
  }

  void _showBrowse(String url, {bool inApp = true}) {
    widget._appNavigator.showBrowse(url, inApp: inApp);
  }

  void _showProfileEditPage(BuildContext context) async {
    User user = await widget._appNavigator
        .showProfileEditScreen(context, widget.user.copy(), _rooms);
    if (user == null) {
      return;
    }
    setState(() {
      widget.user = user;
    });
  }

  void _logout() async {
    await widget._logoutUseCase.execute();
//    Navigator.of(context).pop<User>(null);
    widget._appNavigator.pushReplacementMainScreen(context);
  }

  void _onTapEditTheme() async {
    await widget._appNavigator.showEditThemeScreen(context, widget.user);
    setState(() {
      // something
    });
  }

  void _onTapBlockedUsers() async {
    await widget._appNavigator.showBlockUserListScreen(context, widget.user);
  }

  void _onTapPaidPlan() async {
    User user =
        await widget._appNavigator.showPurchaseScreen(context, widget.user);
    setState(() {
      widget.user = user;
    });
  }
}

class _EditThemeItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  _EditThemeItem({this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16.0, bottom: 0.0),
      child: ListTile(
        title: Text(title),
        trailing:
            Icon(Icons.chevron_right, color: Theme.of(context).disabledColor),
        onTap: onTap,
      ),
    );
  }
}
