import 'package:flutter/material.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/analytics/AnalyticsHelper.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// QRコードを表示するための画面
class DisplayQrCodeScreen extends StatelessWidget implements Screen {
  final String _qrCodeData;

  const DisplayQrCodeScreen(this._qrCodeData);

  @override
  Widget build(BuildContext context) {
    AnalyticsHelper.instance.sendCurrentScreen(this);
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.of(context).qrCode),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.white,
        child: Center(
          child: QrImage(
            version: 10,
            data: _qrCodeData,
            size: 0.2 * bodyHeight,
          ),
        ),
      ),
    );
  }

  @override
  String get name => "/qr";
}
