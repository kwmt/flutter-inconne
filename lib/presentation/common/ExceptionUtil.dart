import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_crashlytics/flutter_crashlytics.dart';
import 'package:instantonnection/domain/model/exception/AddMemberException.dart';
import 'package:instantonnection/domain/model/exception/CameraPermissionException.dart';
import 'package:instantonnection/domain/model/exception/CreateRoomException.dart';
import 'package:instantonnection/domain/model/exception/LeaveRoomException.dart';
import 'package:instantonnection/domain/model/exception/NetworkException.dart';
import 'package:instantonnection/domain/model/exception/PurchaseException.dart';
import 'package:instantonnection/domain/model/exception/SignInException.dart';
import 'package:instantonnection/domain/model/exception/UpdateProfileException.dart';
import 'package:instantonnection/domain/model/exception/UploadImageException.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';

class ExceptionUtil {
  static Future<void> sendCrashlytics(error) {
    return FlutterCrashlytics().logException(error, error.stackTrace);
  }

  static ErrorMessage errorMessage(BuildContext context, dynamic error,
      {StackTrace stackTrace}) {
    if (error is Error) {
      sendCrashlytics(error);
      return ErrorMessage(message: Strings.of(context).unknownError);
    } else {
      Exception e = error as Exception;
      FlutterCrashlytics().logException(e, stackTrace);
      switch (e.runtimeType) {
        case NetworkException:
          return ErrorMessage(message: Strings.of(context).networkError);
        case PurchaseException:
          return ErrorMessage(message: Strings.of(context).purchaseError);
        case LeaveRoomException:
          return ErrorMessage(message: Strings.of(context).leaveRoomError);
        case AddMemberException:
          return ErrorMessage(message: Strings.of(context).addMemberError);
        case CreateRoomException:
          switch ((error as CreateRoomException).type) {
            case CreateRoomExceptionType.QUOTE_EXCEEDED:
              return ErrorMessage(
                  message: Strings.of(context).quoteExceededError,
                  isNavigateToPaidPlan: true);
            case CreateRoomExceptionType.FAILED_ERROR:
              return ErrorMessage(message: Strings.of(context).createRoomError);
          }
          break;
        case UploadImageException:
          switch ((error as UploadImageException).type) {
            case UploadImageExceptionType.QUOTE_EXCEEDED:
              return ErrorMessage(
                  message: Strings.of(context).quoteExceededError,
                  isNavigateToPaidPlan: true);
            case UploadImageExceptionType.UNKNOWN_ERROR:
              return ErrorMessage(
                  message: Strings.of(context).unknownError,
                  isNavigateToPaidPlan: false);
            case UploadImageExceptionType.CANCELED:
              return ErrorMessage(
                  message: Strings.of(context).imageUploadWasCanceled);
          }
          break;
        case SingInCancelledException:
          print("SingInCancelledException");
          break;
        case SingInRequiredException:
          print("SingInRequiredException");
          break;
        case SingInFailedException:
          return ErrorMessage(message: Strings.of(context).singInFailedError);
        case UserRecoverableAuthException:
          return ErrorMessage(
              message: Strings.of(context).userRecoverableAuthError);
        case UpdateProfileException:
          return ErrorMessage(message: Strings.of(context).updateProfileError);
        case CameraPermissionException:
          return ErrorMessage(
              message: Strings.of(context).cameraPermissionError);
      }
    }
    return ErrorMessage(message: Strings.of(context).unknownError);
  }

  static Future<bool> showErrorMessage(
      AppNavigator appNavigator, BuildContext context, dynamic error,
      {StackTrace stackTrace}) async {
    ErrorMessage errorMessage = ExceptionUtil.errorMessage(context, error);
    await appNavigator.showDialogMessage(context,
        message: errorMessage.message,
        isOkOnly: !errorMessage.isNavigateToPaidPlan);
    return _showNavigatePurchase(error);
  }

  /// 購入画面に遷移する場合は、trueを返す
  static Future<bool> _showNavigatePurchase(Exception error) {
    switch (error.runtimeType) {
      case UploadImageException:
        var ex = error as UploadImageException;
        if (ex.type != UploadImageExceptionType.QUOTE_EXCEEDED) {
          // 容量オーバー以外は購入ページに遷移させない
          return Future.value(false);
        }
    }
    return Future.value(true);
  }

  /// エラーメッセージを表示する。
  /// error.code == "E_USER_CANCELLED"の場合はfalseを返す。
  static Future<bool> showErrorMessageIfNeeded(
      AppNavigator appNavigator, BuildContext context, Exception error) {
    if (error is PlatformException) {
      if (error.code == "E_USER_CANCELLED") {
        return Future.value(false);
      }
    }
    return showErrorMessage(appNavigator, context, error);
  }
}

class ErrorMessage {
  String message;

  // 料金ページに遷移するかどうか
  bool isNavigateToPaidPlan;

  ErrorMessage({this.message, this.isNavigateToPaidPlan = false});
}
