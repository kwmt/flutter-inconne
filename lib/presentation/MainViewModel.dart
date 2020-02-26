import 'dart:async';

import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/usecase/FetchCurrentUserUseCase.dart';
import 'package:instantonnection/domain/usecase/GetIsOnboadingSavedUseCase.dart';
import 'package:instantonnection/presentation/common/ExceptionUtil.dart';

enum ViewType { ONBOARDING, PROGRESS, ERROR, SIGNIN, HOME }

/// MainScreenへ通知するためのクラス
class MainViewData {
  static MainViewData _mainViewData;

  ViewType viewType = ViewType.PROGRESS;
  User user;

  MainViewData._();

  factory MainViewData() {
    if (_mainViewData == null) {
      _mainViewData = MainViewData._();
    }
    return _mainViewData;
  }
}

abstract class MainViewModel {
  void init();

  void dispose();

  Stream<MainViewData> get mainViewData;

  User get user;
}

class MainViewModelImpl implements MainViewModel {
  StreamController<MainViewData> _controller = StreamController.broadcast();

  @override
  Stream<MainViewData> get mainViewData => _controller.stream;

  @override
  User user;

  final GetIsOnboadingSavedUseCase getIsOnboadingSavedUseCase;
  final FetchCurrentUserUseCase fetchCurrentUserUseCase;

  final MainViewData _mainViewData = MainViewData();

  MainViewModelImpl(
      this.getIsOnboadingSavedUseCase, this.fetchCurrentUserUseCase);

  @override
  void init() async {
    try {
      bool isOnboardingSaved = await getIsOnboadingSavedUseCase.execute();
      if (isOnboardingSaved) {
        _checkCurrentUser();
      } else {
        _controller.add(_mainViewData..viewType = ViewType.ONBOARDING);
      }
    } catch (error) {
      ExceptionUtil.sendCrashlytics(error);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }

  void _checkCurrentUser() async {
    try {
      user = await fetchCurrentUserUseCase.execute();
      if (user == null) {
        _controller.add(_mainViewData..viewType = ViewType.SIGNIN);
        return;
      }
      _mainViewData
        ..viewType = ViewType.HOME
        ..user = user;
      _controller.add(_mainViewData);
    } catch (error, stactrace) {
      ExceptionUtil.sendCrashlytics(error);
      _controller.add(_mainViewData..viewType = ViewType.ERROR);
    }
  }
}
