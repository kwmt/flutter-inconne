import 'dart:async';

import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/repository/AuthRepository.dart';

abstract class SignInUseCase {
  Future<User> executeWithGoogle();

  Future<User> executeWithFacebook();
}

class SignInUseCaseImpl implements SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCaseImpl(this._authRepository);

  // FIXME: そもそもUserを返す必要はないかも？
  @override
  Future<User> executeWithGoogle() async {
    return _authRepository.signInWithGoogle();
  }

  @override
  Future<User> executeWithFacebook() async {
    return _authRepository.signInWithFacebook();
  }
}
