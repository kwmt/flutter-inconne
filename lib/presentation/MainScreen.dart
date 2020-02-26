import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/presentation/MainViewModel.dart';
import 'package:instantonnection/presentation/common/BaseScreenState.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';
import 'package:instantonnection/presentation/common/progress/Progress.dart';
import 'package:instantonnection/presentation/home/HomeSreen.dart';
import 'package:instantonnection/presentation/onboarding/OnboardingScreen.dart';
import 'package:instantonnection/presentation/signin/SigninScreen.dart';
import 'package:instantonnection/presentation/user/ErrorScreen.dart';

class MainScreen extends StatefulWidget implements Screen {
  final AppNavigator appNavigator;
  final MainViewModel viewModel;

  const MainScreen(
    this.viewModel,
    this.appNavigator,
  );

  @override
  _MainScreenState createState() => _MainScreenState();

  @override
  String get name => "/";
}

class _MainScreenState extends BaseScreenState<MainScreen> {
  User user;

  @override
  void initState() {
    super.initState();
    widget.viewModel.init();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
      initialData: MainViewData(),
      stream: widget.viewModel.mainViewData,
      builder: (BuildContext context, AsyncSnapshot<MainViewData> snapshot) {
        switch (snapshot.data.viewType) {
          case ViewType.ONBOARDING:
            return Injector.getInjector().get<OnboardingScreen>();
          case ViewType.PROGRESS:
            return Progress();
          case ViewType.ERROR:
            return ErrorScreen(widget.appNavigator);
          case ViewType.SIGNIN:
            return Injector.getInjector().get<MySignInScreen>();
          case ViewType.HOME:
            return Injector.getInjector()
                .get<HomeScreen>(additionalParameters: {"user": snapshot.data.user});
        }
      });
}
