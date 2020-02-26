import 'dart:async';

import 'package:instantonnection/domain/model/AppTheme.dart';
import 'package:instantonnection/domain/model/Receipt.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/repository/AuthRepository.dart';
import 'package:instantonnection/domain/repository/PurchaseRepository.dart';
import 'package:instantonnection/domain/repository/UserRepository.dart';
import 'package:instantonnection/domain/usecase/PurchaseUseCase.dart';
import 'package:instantonnection/infrastructure/entity/ThemeEntity.dart';
import 'package:instantonnection/infrastructure/translator/ThemeTranslator.dart';

/// 現在のユーザーを取得する。nullの場合は未ログイン
abstract class FetchCurrentUserUseCase {
  Future<User> execute();
}

class FetchCurrentUserUseCaseImpl implements FetchCurrentUserUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final PurchaseRepository _purchaseRepository;
  final PurchaseUseCase _purchaseUseCase;

  FetchCurrentUserUseCaseImpl(this._authRepository, this._userRepository,
      this._purchaseRepository, this._purchaseUseCase);

  User cachedUser;

  @override
  Future<User> execute() async {
    User user = await _authRepository.currentUser();
    if (user == null) {
      return null;
    }

    if (cachedUser != null) {
      return cachedUser;
    }
    // ユーザー情報取得
    // このとき支払い情報も取得している
    user = await _userRepository.fetchUser(user);
    // 新規登録してFirestoreからuserを取得しようとするが、
    // そのときはまだuserが作成されてないため、userEntityはnullの場合がありえる。
    if (user == null) {
      return null;
    }

    // 購入したことがある場合のみ
    if (user.paidPlan.transactionReceipt != null) {
      // キャンセル・解約しているか・有効期限が切れないか確認する確認する
      var latestReceipt = await _purchaseRepository.validateReceipt(user);

      if (latestReceipt != null &&
          user.paidPlan.paidType != latestReceipt.latestReceipt.paidType) {
        // DBに登録しているPlanとappstoreやplaystoreに問い合わせて確認したプランが異なっている場合
        // (解約・通信障害でDBに登録できなかったなど)DBを最新に更新する
        user = await _purchaseUseCase.updatePaidPlan(
            user,
            latestReceipt.latestReceipt.paidType,
            user.paidPlan,
            latestReceipt.latestReceipt.productId,
            latestReceipt.os == Os.Android
                ? latestReceipt.transactionReceipt
                : null,
            latestReceipt.os == Os.iOS
                ? latestReceipt.transactionReceipt
                : null);
      }
    }

    List<AppTheme> themeEntityList = await _userRepository.fetchThemes();

    user.theme = themeEntityList.firstWhere(
        (themeEntity) => themeEntity.id == user.theme.id,
        // FIXME: ThemeTranslatorとThemeEntityはinfra層なので、domain層から参照してはいけない
        orElse: () => ThemeTranslator().toModel(ThemeEntity()));

    // ブロックユーザーリストを取得
    user.blockUserList = await _userRepository.fetchBlockUsers(user);

    cachedUser = user;
    return cachedUser;
  }
}
