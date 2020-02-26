import 'package:flutter/material.dart';
import 'package:instantonnection/domain/usecase/SaveIsOnboadingReadUseCase.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';

class OnboardingScreen extends StatefulWidget implements Screen {
  final SaveIsOnboadingReadUseCase saveIsOnboadingReadUseCase;
  final AppNavigator appNavigator;

  const OnboardingScreen(
      {Key key, this.saveIsOnboadingReadUseCase, this.appNavigator})
      : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();

  @override
  String get name => "/onboarding";
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<_Page> _pages;

  List<_Page> createPages(BuildContext context) => <_Page>[
        _Page(
            Image.asset("assets/images/tutorial/Onboarding1.png"),
            Strings.of(context).onboarding1Title,
            Strings.of(context).onboarding1Message,
            Color(0xFFEC7C7C)),
        _Page(
            Image.asset("assets/images/tutorial/Onboarding2.png"),
            Strings.of(context).onboarding2Title,
            Strings.of(context).onboarding2Message,
            Color(0xFF61ABEB)),
        _Page(
            Image.asset("assets/images/tutorial/Onboarding3.png"),
            Strings.of(context).onboarding3Title,
            Strings.of(context).onboarding3Message,
            Color(0xFF009688)),
        _Page(
            Image.asset("assets/images/tutorial/Onboarding4.png"),
            Strings.of(context).onboarding4Title,
            Strings.of(context).onboarding4Message,
            Color(0xFFFF9800)),
      ];

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      _pages = createPages(context);
      _tabController =
          TabController(initialIndex: 0, vsync: this, length: _pages.length);
    }

    return Scaffold(
      body: _PageSelector(
        pages: _pages,
        tabController: _tabController,
        saveIsOnboadingReadUseCase: widget.saveIsOnboadingReadUseCase,
        appNavigator: widget.appNavigator,
      ),
    );
  }
}

class _Page {
  final Widget image;
  final String title;
  final String message;
  final Color color;

  _Page(this.image, this.title, this.message, this.color);
}

class _PageSelector extends StatelessWidget {
  final List<_Page> pages;
  final TabController tabController;
  final SaveIsOnboadingReadUseCase saveIsOnboadingReadUseCase;
  final AppNavigator appNavigator;

  _PageSelector(
      {this.pages,
      this.tabController,
      this.saveIsOnboadingReadUseCase,
      this.appNavigator});

  Widget _buildOnboardinWidget(BuildContext context, int index, _Page page) {
    final ButtonThemeData buttonTheme = ButtonTheme.of(context);

    List<Widget> widgets = <Widget>[
      Text(
        page.title,
        style: TextStyle(color: Colors.white, fontSize: 28),
      ),
      Padding(
        padding: EdgeInsets.only(top: 16.0, bottom: 8.0, left: 8.0, right: 8.0),
        child: Text(
          page.message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    ];

    if (index == tabController.length - 1) {
      Widget button = Container(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: ButtonTheme(
          minWidth: double.infinity,
          height: 45.0,
          child: RaisedButton(
            color: Color(0xFF009688),
            textColor: Colors.white,
            child: Text(Strings.of(context).onboardingStartMessage),
            onPressed: () => _onTapStartButton(context),
          ),
        ),
      );
      widgets.add(button);
    }

    return Container(
      color: page.color,
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: page.image,
            flex: 3,
          ),
          Expanded(
            child: Column(
              children: widgets,
            ),
            flex: 2,
          ),
          //your elements here
        ],
      ),
    );
  }

  void _onTapStartButton(BuildContext context) async {
    try {
      await saveIsOnboadingReadUseCase.execute();
      appNavigator.pushReplacementMainScreen(context);
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Column(
        children: <Widget>[
          Expanded(
            child: TabBarView(
                controller: tabController,
                children: pages
                    .asMap()
                    .map((int i, _Page page) =>
                        MapEntry(i, _buildOnboardinWidget(context, i, page)))
                    .values
                    .toList()),
          ),
          Container(
            margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: TabPageSelector(controller: tabController),
          ),
        ],
      ),
    );
  }
}
