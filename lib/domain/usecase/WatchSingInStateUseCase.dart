import 'dart:async';

import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/repository/AuthRepository.dart';
import 'package:instantonnection/domain/usecase/FetchCurrentUserUseCase.dart';

/// ログイン状態を監視する
abstract class WatchSingInStateUseCase {
  StreamSubscription execute(void onChanged(User user));
}

class WatchSingInStateUseCaseImpl implements WatchSingInStateUseCase {
  final AuthRepository _authRepository;
  final FetchCurrentUserUseCase _fetchCurrentUserUseCase;

  WatchSingInStateUseCaseImpl(
      this._authRepository, this._fetchCurrentUserUseCase);

  @override
  StreamSubscription execute(void onChanged(User user)) {
    return _authRepository.watch((userEntity) {
      if (userEntity == null) {
        onChanged(null);
        return;
      }
      _fetchCurrentUserUseCase.execute().then((fetchedUser) {
        User user = fetchedUser;
        // 新規登録時、ログイン状態に変更がありauthenticationにはユーザーは登録されたが、
        // Firestoreには登録されてないため、fetchedUserはnullの場合がありえる。
        if (user == null) {
          user = userEntity;
        }
        onChanged(user);
      });
    });
  }
}
