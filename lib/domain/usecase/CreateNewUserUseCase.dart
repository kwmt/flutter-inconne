import 'dart:async';

import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/repository/UserRepository.dart';

/// 新規ユーザーを作成する
abstract class CreateNewUserUseCase {
  Future<User> execute(User user);
}

class CreateNewUserUseCaseImpl implements CreateNewUserUseCase {
  final UserRepository _userRepository;

  CreateNewUserUseCaseImpl(this._userRepository);

  @override
  Future<User> execute(User user) async {
    return await _userRepository.createNewUser(user);
  }
}
