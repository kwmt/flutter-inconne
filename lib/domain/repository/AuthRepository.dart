import 'dart:async';

import 'package:instantonnection/domain/model/User.dart';

abstract class AuthRepository {
  StreamSubscription watch(void onChanged(User user));

  Future<User> currentUser();

  /// ユーザープロフィールを更新する
  /// 認証サービス(Firebase Auth)のユーザー情報を更新する
  Future<void> updateUserProfile(User user);

  Future<User> signInWithGoogle();

  Future<User> signInWithFacebook();

  Future<void> logout();
}
