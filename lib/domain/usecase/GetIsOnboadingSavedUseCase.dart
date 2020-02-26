import 'dart:async';

import 'package:instantonnection/domain/repository/LocalStorageRepository.dart';

/// Onboadingを表示したかどうかを取得する
/// true: 表示したことがある
abstract class GetIsOnboadingSavedUseCase {
  Future<bool> execute();
}

class GetIsOnboadingSavedUseCaseImpl implements GetIsOnboadingSavedUseCase {
  final LocalStorageRepository _localStorageRepository;

  GetIsOnboadingSavedUseCaseImpl(this._localStorageRepository);

  @override
  Future<bool> execute() => _localStorageRepository.isOnboadingSaved();
}
