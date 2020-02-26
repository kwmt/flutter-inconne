import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:instantonnection/application/AppConfig.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/usecase/CreateNewUserUseCase.dart';
import 'package:instantonnection/domain/usecase/SignInUseCase.dart';
import 'package:instantonnection/domain/usecase/WatchSingInStateUseCase.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/BaseScreenState.dart';
import 'package:instantonnection/presentation/common/ExceptionUtil.dart';
import 'package:instantonnection/presentation/common/LinkTextSpan.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';
import 'package:instantonnection/presentation/signin/signin_button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class MySignInScreen extends StatefulWidget implements Screen {
  final CreateNewUserUseCase createNewUserUseCase;
  final WatchSingInStateUseCase watchSingInStateUseCase;
  final SignInUseCase signInUseCase;
  final AppNavigator appNavigator;

  MySignInScreen(
    this.createNewUserUseCase,
    this.watchSingInStateUseCase,
    this.signInUseCase,
    this.appNavigator,
  );

  @override
  _MySignInScreenState createState() => _MySignInScreenState();

  @override
  String get name => "/signin";

}

class _MySignInScreenState extends BaseScreenState<MySignInScreen> {
  StreamSubscription _listener;

  bool _isAgree = false;

  bool _isProgress = false;

  bool _alreadyNavigated = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Center(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      value: _isAgree,
                      onChanged: (bool value) {
                        setState(() {
                          _isAgree = !_isAgree;
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 16.0),
                          children: _createTermsAndPrivacyLink(context),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              MaterialButton(
                child: signInButton(Strings.of(context).signInWithGoogle,
                    'assets/images/google.png'),
                onPressed: _isAgree ? _handleSignInWithGoogle : _showError,
                color: Colors.white,
              ),
              Padding(padding: EdgeInsets.all(10.0)),
              MaterialButton(
                child: signInButton(Strings.of(context).signInWithFacebook,
                    'assets/images/facebook.png', Colors.white),
                onPressed: () {
                  try {
                    _isAgree ? _handleSignInWithFacebook() : _showError();
                  } catch (e) {
                    _showError(message: e.toString());
                  }
                },
                color: Color.fromRGBO(58, 89, 152, 1.0),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.of(context).signIn),
      ),
      body: ModalProgressHUD(child: body, inAsyncCall: _isProgress),
    );
  }

  List<TextSpan> _createTermsAndPrivacyLink(BuildContext context) {
    TextStyle textStyle = TextStyle(color: Colors.black54);
    TextSpan iAgree =
        TextSpan(text: Strings.of(context).iAgree, style: textStyle);
    List<TextSpan> termsAndPrivacy = <TextSpan>[
      LinkTextSpan(
          text: Strings.of(context).terms,
          url: AppConfig.of(context).termsUrl,
          inAppWebView: true),
      TextSpan(text: Strings.of(context).and, style: textStyle),
      LinkTextSpan(
          text: Strings.of(context).privacy,
          url: AppConfig.of(context).privacyPolicyUrl,
          inAppWebView: true),
    ];

    if (Localizations.localeOf(context).languageCode == 'ja') {
      termsAndPrivacy.add(iAgree);
    } else {
      termsAndPrivacy.insert(0, iAgree);
    }

    return termsAndPrivacy;
  }

  Future<User> _handleSignInWithGoogle() async {
    _toggleProgress(show: true);
    try {
      User user = await widget.signInUseCase.executeWithGoogle();
      _toggleProgress();
      _checkCurrentUser();
      return user;
    } catch (error) {
      _toggleProgress();
      ExceptionUtil.showErrorMessageIfNeeded(
          widget.appNavigator, context, error);
    }
  }

  Future<User> _handleSignInWithFacebook() async {
    _toggleProgress(show: true);
    try {
      User user = await widget.signInUseCase.executeWithFacebook();
      _toggleProgress();
      _checkCurrentUser();
      return user;
    } catch (error) {
      _toggleProgress();
      ExceptionUtil.showErrorMessageIfNeeded(
          widget.appNavigator, context, error);
    }
    return null;
  }

  void _showError({String message}) async {
    if (message == null) {
      message = Strings.of(context).youMustAgree;
    }
    widget.appNavigator
        .showDialogMessage(context, message: message, isOkOnly: true);
  }

  void _checkCurrentUser() async {
    try {
      _toggleProgress(show: true);
      _listener = widget.watchSingInStateUseCase.execute((User user) {
        if (user == null) {
          _toggleProgress();
          return;
        }
//      _navigate(user);

        widget.createNewUserUseCase.execute(user).then((newUser) {
          _toggleProgress();
          _navigate(newUser);
        }).catchError((e) {
          _toggleProgress();
        });
      });
    } catch (error) {
      _toggleProgress();
    }
  }

  void _navigate(User user) {
    if (_alreadyNavigated) {
      return;
    }

    if (Navigator.canPop(context)) {
      Navigator.of(context).pop<User>(user);
      return;
    }
    _alreadyNavigated = true;
    Injector.getInjector()
        .get<AppNavigator>()
        .pushReplacementHomeScreen(context, user);
  }

  void _toggleProgress({bool show = false}) {
    if (!mounted) {
      return;
    }
    setState(() {
      _isProgress = show;
    });
  }
}
