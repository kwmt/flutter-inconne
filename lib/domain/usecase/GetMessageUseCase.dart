import 'dart:async';

import 'package:instantonnection/domain/repository/LocalStorageRepository.dart';

abstract class GetMessageUseCase {
  Future<String> execute(String roomId);
}

class GetMessageUseCaseImpl implements GetMessageUseCase {
  final LocalStorageRepository _localStorageRepository;

  GetMessageUseCaseImpl(this._localStorageRepository);

  @override
  Future<String> execute(String roomId) {
    return _localStorageRepository.getMessage(roomId);
  }
}
