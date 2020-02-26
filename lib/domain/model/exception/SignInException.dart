abstract class SignInException implements Exception {
  final String code;
  final String message;

  SignInException({this.code, this.message});
}

class SingInCancelledException extends SignInException {
  SingInCancelledException({String code, String message})
      : super(code: code, message: message);
}

class SingInRequiredException extends SignInException {
  SingInRequiredException({String code, String message})
      : super(code: code, message: message);
}

class SingInFailedException extends SignInException {
  SingInFailedException({String code, String message})
      : super(code: code, message: message);
}

class UserRecoverableAuthException extends SignInException {
  UserRecoverableAuthException({String code, String message})
      : super(code: code, message: message);
}

/// https://developers.google.com/android/reference/com/google/android/gms/auth/api/signin/GoogleSignInStatusCodes.html#SIGN_IN_FAILED
//enum SignInExceptionType {
//  SIGN_IN_CANCELLED,
//  SIGN_IN_CURRENTLY_IN_PROGRESS,
//  SIGN_IN_FAILED
//}
