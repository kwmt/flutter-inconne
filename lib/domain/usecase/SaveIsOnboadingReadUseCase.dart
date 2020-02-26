import 'dart:async';

import 'package:instantonnection/domain/repository/LocalStorageRepository.dart';

abstract class SaveIsOnboadingReadUseCase {
  Future<bool> execute();
}

class SaveIsOnboadingReadUseCaseImpl implements SaveIsOnboadingReadUseCase {
  final LocalStorageRepository _localStorageRepository;

  SaveIsOnboadingReadUseCaseImpl(this._localStorageRepository);

  @override
  Future<bool> execute() => _localStorageRepository.saveIsOnboarding();
}
