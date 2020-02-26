import 'package:flutter/material.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/analytics/AnalyticsHelper.dart';

abstract class BaseScreenState<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    AnalyticsHelper.instance.sendCurrentScreen(widget as Screen);
  }
}
