import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/model/exception/NetworkException.dart';
import 'package:instantonnection/domain/model/exception/SignInException.dart';
import 'package:instantonnection/domain/model/exception/UpdateProfileException.dart';
import 'package:instantonnection/domain/repository/AuthRepository.dart';
import 'package:instantonnection/infrastructure/entity/UserEntity.dart';
import 'package:instantonnection/infrastructure/translator/UserTranslator.dart';

class FirebaseAuthDatasource implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final UserTranslator userTranslator = UserTranslator();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email'],
  );

  final FacebookLogin _facebookSignIn = FacebookLogin();

  @override
  StreamSubscription watch(void onChanged(User user)) {
    return _auth.onAuthStateChanged.listen((FirebaseUser firebaseUser) {
      if (firebaseUser == null) {
        onChanged(null);
      } else {
        onChanged(userTranslator.toModel(_firebaseUserToUser(firebaseUser)));
      }
    });
  }

  @override
  Future<User> currentUser() async {
    try {
      FirebaseUser firebaseUser = await _auth.currentUser();
      await firebaseUser?.getIdToken(refresh: true);
      if (firebaseUser != null) {
        return Future.value(
            userTranslator.toModel(_firebaseUserToUser(firebaseUser)));
      }
      return Future.value(null);
    } catch (e) {
      /// FIXME: PlatformExceptionをキャッチするのだが、どのタイプのエラーでもcodeが"exception"になっているようで、ネットワークエラーかどうか分からない。
      /// messageに 「A network error 〜」と書いているので、最悪それを見つけて判断するしか無いかも？
      /// Networkエラーが多いと思うので、NetworkExceptionとして例外を投げることにする。
      throw NetworkException(message: e?.message);
    }
  }

  @override
  Future<void> updateUserProfile(User user) async {
    UserUpdateInfo userUpdateInfo = UserUpdateInfo()
      ..displayName = user.name
      ..photoUrl = user.photoUrl;
    try {
      FirebaseUser _currentUser = await _auth.currentUser();
      await _currentUser.updateProfile(userUpdateInfo);
    } catch (e) {
      throw UpdateProfileException(message: e?.message);
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // キャンセルならnullを返す
        return null;
      }
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      return userTranslator.toModel(_firebaseUserToUser(user));
    } catch (error) {
      print(error);
      if (error is PlatformException) {
        switch (error.code) {
          case GoogleSignIn.kSignInFailedError:
            throw SingInFailedException(
                code: error.code, message: error.details);
          case GoogleSignIn.kSignInCanceledError:
            throw SingInCancelledException(
                code: error.code, message: error.details);
          case GoogleSignIn.kSignInRequiredError:
            throw SingInRequiredException(
                code: error.code, message: error.details);
          case GoogleSignInAccount.kFailedToRecoverAuthError:
            // もう少し適切なものがあるかもしれないが、このエラーの発生再現が難しいので、現状これでいく
            throw SingInFailedException(
                code: error.code, message: error.details);
          case GoogleSignInAccount.kUserRecoverableAuthError:
            throw UserRecoverableAuthException(
                code: error.code, message: error.details);
          default:
            throw SingInFailedException(
                code: error.code, message: error.details);
        }
      }
      return null;
    }
  }

  @override
  Future<User> signInWithFacebook() async {
    try {
      final FacebookLoginResult result =
          await _facebookSignIn.logIn(['email']);
      switch (result.status) {
        case FacebookLoginStatus.cancelledByUser:
          // キャンセルならnullを返す
          return null;
        case FacebookLoginStatus.error:
          throw SingInFailedException(message: result.errorMessage);
        case FacebookLoginStatus.loggedIn:
          final AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token,
          );
          return _auth.signInWithCredential(credential).then((authResult) =>
              userTranslator.toModel(_firebaseUserToUser(authResult.user))
          );
      }
    } catch (error) {
      print(error);
      if (error is PlatformException) {
        switch (error.code) {
          case GoogleSignIn.kSignInFailedError:
            throw SingInFailedException(
                code: error.code, message: error.details);
          case GoogleSignIn.kSignInCanceledError:
            throw SingInCancelledException(
                code: error.code, message: error.details);
          case GoogleSignIn.kSignInRequiredError:
            throw SingInRequiredException(
                code: error.code, message: error.details);
          default:
            throw SingInFailedException(
                code: error.code, message: error.details);
        }
      }
      return null;
    }
    return null; // dead
  }

  @override
  Future<void> logout() {
    return _auth.signOut();
  }

  UserEntity _firebaseUserToUser(FirebaseUser firebaseUser) {
    return UserEntity(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName,
        email: firebaseUser.email,
        photoUrl: firebaseUser.photoUrl);
  }
}
