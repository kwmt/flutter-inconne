import 'dart:async';

import 'package:instantonnection/domain/repository/AuthRepository.dart';

abstract class LogoutUseCase {
  Future execute();
}

class LogoutUseCaseImpl implements LogoutUseCase {
  final AuthRepository _authRepository;

  LogoutUseCaseImpl(this._authRepository);

  @override
  Future execute() {
    return _authRepository.logout();
  }
}
