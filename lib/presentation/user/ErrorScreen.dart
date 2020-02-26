import 'package:flutter/material.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';

class ErrorScreen extends StatelessWidget {
  final AppNavigator appNavigator;

  ErrorScreen(this.appNavigator);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.of(context).errorOccurred)),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(Strings.of(context).encouragedError),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: RaisedButton(
                    child: Text(Strings.of(context).contactUs),
                    onPressed: _showBrowse),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showBrowse() {
    appNavigator.showBrowse("https://goo.gl/forms/O8IiBFxmux6gNB0V2",
        inApp: false);
  }
}
