import 'dart:async';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/model/exception/CameraPermissionException.dart';
import 'package:instantonnection/domain/usecase/AddMemberToRoomUseCase.dart';
import 'package:instantonnection/domain/usecase/UpdatePushNotificationSubscriptionUseCase.dart';
import 'package:instantonnection/presentation/common/ExceptionUtil.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';
//import 'package:qr_reader/qr_reader.dart';

/// Roomに参加するための画面
/// RoomIdをPush通知のトピックとしてsubscribeする
class JoinRoomReader {
  final AppNavigator _appNavigator;
  final AddMemberToRoomUseCase addMemberToRoomUseCase;
  final UpdatePushNotificationSubscriptionUseCase
      _updatePushNotificationSubscriptionUseCase;

  JoinRoomReader(this._appNavigator, this.addMemberToRoomUseCase,
      this._updatePushNotificationSubscriptionUseCase);

  String _roomId;

  Future<String> scan(BuildContext context, User user) async {
    await _appNavigator.showJoinRoomSelector(
        context,
        () => _joinRoomWithCamera(context),
        () => _joinRoomWithQRImage(context));

    if (_roomId == null) {
      return Future.value(null);
    }
    Room room = Room(id: _roomId);

    List<String> topics = List<String>()..add(_roomId)..add(user.uid);
    await Future.wait([
      addMemberToRoomUseCase.execute(room, user),
      _updatePushNotificationSubscriptionUseCase.subscribeTopics(topics)
    ]);

    return Future.value(_roomId);
  }

  /// カメラを使ってQRコードをスキャンしてRoomに参加する
  void _joinRoomWithCamera(BuildContext context) async {
    try {
      _roomId = await BarcodeScanner.scan();
      Navigator.of(context).pop();
    } catch (error) {
      if (error is PlatformException &&
          error.code == BarcodeScanner.CameraAccessDenied) {
        ExceptionUtil.showErrorMessage(
            _appNavigator, context, CameraPermissionException(error));
      }
    }
  }

  /// QRコード画像を読み取ってRoomに参加する
  void _joinRoomWithQRImage(BuildContext context) async {
    await _onImageButtonPressed(ImageSource.gallery);
    Navigator.of(context).pop();
  }

  Future<void> _onImageButtonPressed(ImageSource source) async {
    File selectedImageFile = await ImagePicker.pickImage(source: source);
    if (selectedImageFile == null) {
      return;
    }

    FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(selectedImageFile);

    final BarcodeDetectorOptions options = BarcodeDetectorOptions();
    final BarcodeDetector barcodeDetector =
        FirebaseVision.instance.barcodeDetector();
    final List<Barcode> barcodes =
        await barcodeDetector.detectInImage(visionImage);

    for (Barcode barcode in barcodes) {
      final BarcodeValueType valueType = barcode.valueType;

      // See API reference for complete list of supported types
      switch (valueType) {
        case BarcodeValueType.text:
          final String value = barcode.displayValue;
          _roomId = value;
          break;
        default:
          break;
      }
    }
  }
}
