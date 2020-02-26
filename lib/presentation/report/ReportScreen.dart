import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instantonnection/domain/model/Message.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/usecase/ReportUseCase.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/BaseScreenState.dart';
import 'package:instantonnection/presentation/common/ExceptionUtil.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ReportScreen extends StatefulWidget implements Screen {
  final User user;
  final Room room;
  final Message message;
  final ReportUseCase reportRoomUseCase;
  final AppNavigator appNavigator;

  ReportScreen(
      {this.user,
      this.room,
      this.message,
      this.reportRoomUseCase,
      this.appNavigator}) {
    assert(user != null);
    assert(room != null);
    assert(appNavigator != null);
    assert(reportRoomUseCase != null);
  }

  @override
  _ReportScreenState createState() => _ReportScreenState();

  @override
  String get name => "/report";
}

class _ReportScreenState extends BaseScreenState<ReportScreen> {
  bool _updating = false;

  @override
  Widget build(BuildContext context) {
    Widget _body = CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(Strings.of(context).reportTitle),
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate(<Widget>[
          AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark, child: _bodyContent(context)),
        ])),
      ],
    );

    return Scaffold(
      body: ModalProgressHUD(child: _body, inAsyncCall: _updating),
    );
  }

  Widget _bodyContent(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                _reportDescription(context),
                _reportReasonList(context),
                _checkDescription(context),
                RaisedButton(
                  child: Text(Strings.of(context).agreeAndSend),
                  onPressed: () => _onTapReportButton(context),
                )
              ],
            )
          ],
        ));
  }

  ReportType _radioValue = ReportType.SPAM;

  Widget _reportDescription(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: Text(Strings.of(context).reportDescription));
  }

  Widget _reportReasonList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ReportType.values
              .map((type) => Report(type))
              .map((report) => _reportItem(report.type, report.text(context)))
              .toList()),
    );
  }

  Widget _reportItem(ReportType type, String content) {
    return RadioListTile<ReportType>(
      title: Text(content),
      value: type,
      groupValue: _radioValue,
      onChanged: (ReportType value) {
        setState(() {
          _radioValue = value;
        });
      },
    );
  }

  Widget _checkDescription(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Text(Strings.of(context).reportCheckDescription));
  }

  void _onTapReportButton(BuildContext context) async {
    bool isOk = await widget.appNavigator.showDialogMessage(context,
        message: Strings.of(context).checkReportRoom);
    if (!isOk) {
      return;
    }
    setState(() {
      _updating = true;
    });

    try {
      if (widget.message != null) {
        await widget.reportRoomUseCase.reportMessage(
            widget.user, widget.room, _radioValue, widget.message);
      } else {
        await widget.reportRoomUseCase
            .reportRoom(widget.user, widget.room, _radioValue);
      }
      await widget.appNavigator.showDialogMessage(context,
          message: Strings.of(context).thankYouReport);
      await Navigator.of(context).pop(true);
    } catch (error) {
      ExceptionUtil.showErrorMessageIfNeeded(
          widget.appNavigator, context, error);
    } finally {
      setState(() {
        _updating = false;
      });
    }
  }
}

enum ReportType { SPAM, SEXUAL_HARASSMENT, OTHER_HARASSMENT, OTHER }

class Report {
  ReportType type;

  Report(this.type);

  String text(BuildContext context) {
    switch (type) {
      case ReportType.SPAM:
        return Strings.of(context).reportTypeSpam;
      case ReportType.SEXUAL_HARASSMENT:
        return Strings.of(context).reportTypeSexualHarassment;
      case ReportType.OTHER_HARASSMENT:
        return Strings.of(context).reportTypeOtherHarassment;
      case ReportType.OTHER:
        return Strings.of(context).reportTypeOther;
      default:
        return Strings.of(context).reportTypeSpam;
    }
  }
}
