import 'dart:async';

import 'package:instantonnection/domain/model/AppTheme.dart';
import 'package:instantonnection/domain/repository/UserRepository.dart';

/// Themeリストを取得する
abstract class FetchThemeListUseCase {
  Future<List<AppTheme>> execute();
}

class FetchThemeListUseCaseImpl implements FetchThemeListUseCase {
  final UserRepository userRepository;

  FetchThemeListUseCaseImpl(this.userRepository);

  @override
  Future<List<AppTheme>> execute() {
    return userRepository.fetchThemes();
  }
}
