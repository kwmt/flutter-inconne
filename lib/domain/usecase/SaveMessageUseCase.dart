import 'dart:async';

import 'package:instantonnection/domain/model/Message.dart';
import 'package:instantonnection/domain/repository/LocalStorageRepository.dart';

abstract class SaveMessageUseCase {
  Future<bool> execute(Message message, String roomId);
}

class SaveMessageUseCaseImpl implements SaveMessageUseCase {
  final LocalStorageRepository _localStorageRepository;

  SaveMessageUseCaseImpl(this._localStorageRepository);

  @override
  Future<bool> execute(Message message, String roomId) {
    return _localStorageRepository.saveMessage(message, roomId);
  }
}
