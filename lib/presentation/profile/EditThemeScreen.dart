import 'package:flutter/material.dart';
import 'package:instantonnection/application/AppConfig.dart';
import 'package:instantonnection/domain/model/AppTheme.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/usecase/FetchThemeListUseCase.dart';
import 'package:instantonnection/domain/usecase/UpdateUserProfileUseCase.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/analytics/AnalyticsHelper.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';
import 'package:instantonnection/presentation/common/BaseScreenState.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class EditThemeScreen extends StatefulWidget implements Screen {
  final User user;
  final AppNavigator appNavigator;
  final FetchThemeListUseCase fetchThemeListUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  const EditThemeScreen(
      {Key key,
      this.user,
      this.appNavigator,
      this.fetchThemeListUseCase,
      this.updateUserProfileUseCase})
      : super(key: key);

  @override
  _EditThemeScreenState createState() => _EditThemeScreenState();

  @override
  String get name => "/profile/edit/theme";
}

class _EditThemeScreenState extends BaseScreenState<EditThemeScreen> {
  bool _isProgress = false;

  List<AppTheme> themeList = List();

  @override
  void initState() {
    super.initState();

    _isProgress = true;
    widget.fetchThemeListUseCase.execute().then((themeList) {
      setState(() {
        _isProgress = false;
        this.themeList = themeList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          backgroundColor: AppConfig.kTheme.primaryColor,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(Strings.of(context).settingColorThemeTitle),
          ),
        ),
        SliverFixedExtentList(
          itemExtent: 60.0,
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            AppTheme theme = this.themeList[index];
            return ColorItem(
              theme,
              widget.user,
              onTap: () => _onTapColorItem(theme, context),
            );
          }, childCount: this.themeList.length),
        ),
      ],
    );

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        body: ModalProgressHUD(child: body, inAsyncCall: _isProgress),
      ),
    );
  }

  void _onTapColorItem(AppTheme theme, BuildContext context) {
    setState(() {
      widget.user.theme.id = theme.id;
    });

    widget.updateUserProfileUseCase.execute(widget.user).then((success) {
      setState(() {
        AppConfig.setAppTheme(theme);
      });
      AnalyticsHelper.instance.sendChangeTheme(theme.id);
      widget.appNavigator
          .showSnackBar(context, (Strings.of(context).changedColorTheme));
    });
  }
}

class ColorItem extends StatelessWidget {
  final AppTheme theme;
  final User user;
  final VoidCallback onTap;

  const ColorItem(this.theme, this.user, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin:
            const EdgeInsets.only(left: 8.0, top: 4.0, right: 8.0, bottom: 4.0),
        color: theme.primary,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                theme.name,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: theme.id == user.theme.id
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
