import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:instantonnection/domain/model/AppTheme.dart';
import 'package:instantonnection/domain/model/PaidPlan.dart';
import 'package:instantonnection/domain/model/Receipt.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/model/util/EnumUtil.dart';
import 'package:instantonnection/domain/repository/AuthRepository.dart';
import 'package:instantonnection/domain/repository/PurchaseRepository.dart';
import 'package:instantonnection/domain/repository/UserRepository.dart';
import 'package:instantonnection/domain/usecase/FetchCurrentUserUseCase.dart';
import 'package:instantonnection/domain/usecase/PurchaseUseCase.dart';
import 'package:instantonnection/infrastructure/entity/PaidPlanEntity.dart';
import 'package:instantonnection/infrastructure/entity/ThemeEntity.dart';
import 'package:instantonnection/infrastructure/entity/UserEntity.dart';
import 'package:instantonnection/infrastructure/translator/ThemeTranslator.dart';
import 'package:instantonnection/infrastructure/translator/UserTranslator.dart';
import 'package:mockito/mockito.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockPurchaseRepository extends Mock implements PurchaseRepository {}

class MockPurchaseUseCase extends Mock implements PurchaseUseCase {}

void main() {
  UserTranslator userTranslator = UserTranslator();
  ThemeTranslator themeTranslator = ThemeTranslator();

  group('ユーザー情報取得の確認', () {
    FetchCurrentUserUseCase target;
    MockAuthRepository mockAuthRepository;
    MockUserRepository mockUserRepository;
    MockPurchaseRepository mockPurchaseRepository;
    MockPurchaseUseCase mockPurchaseUseCase;

    setUpAll(() async {
      mockAuthRepository = MockAuthRepository();
      mockUserRepository = MockUserRepository();
      mockPurchaseRepository = MockPurchaseRepository();
      mockPurchaseUseCase = MockPurchaseUseCase();

      target = FetchCurrentUserUseCaseImpl(mockAuthRepository,
          mockUserRepository, mockPurchaseRepository, mockPurchaseUseCase);
    });

    test('未登録の時、Userがnullであることを確認', () async {
      when(mockAuthRepository.currentUser()).thenAnswer((_) => null);
      User user = await target.execute();
      expect(user, isNull);
    });

    test('新規登録済み(Databaseに登録済み)・ログイン済みの時、ユーザー情報の取得を確認', () async {
      // given
      User testAuthUser = userTranslator.toModel(UserEntity(uid: "1"));
      User testUser = userTranslator.toModel(UserEntity(
          uid: "1",
          name: "taro",
          email: "taro-mail",
          photoUrl: "url",
          themeId: "testId",
          paidPlanEntity:
              PaidPlanEntity(itemId: EnumUtil.getValueString(PaidType.Free))));

      List<AppTheme> testThemeList = [
        themeTranslator.toModel(ThemeEntity(
            id: "testId", primary: "0xFF111111", accent: "0xFF222222"))
      ];

      LatestReceipt latestReceipt = LatestReceipt(
          latestReceipt: Receipt(productId: "Free"),
          transactionReceipt: "testLatestReceipt");

      // when
      when(mockAuthRepository.currentUser())
          .thenAnswer((_) => Future.value(testAuthUser));
      when(mockUserRepository.fetchUser(testAuthUser))
          .thenAnswer((_) => Future.value(testUser));
      when(mockUserRepository.fetchThemes())
          .thenAnswer((_) => Future.value(testThemeList));
      when(mockPurchaseRepository.validateReceipt(testUser))
          .thenAnswer((_) => Future.value(latestReceipt));
      when(mockPurchaseUseCase.updatePaidPlan(
              testUser,
              latestReceipt.latestReceipt.paidType,
              testUser.paidPlan,
              latestReceipt.latestReceipt.productId,
              latestReceipt.transactionReceipt,
              latestReceipt.transactionReceipt))
          .thenAnswer((_) => Future.value(testUser));

      // then
      User user = await target.execute();
      expect(user.name, user.name);

      AppTheme appTheme = testThemeList[0];
      expect(user.theme.primary.value, appTheme.primary.value);
    });
  });

  group('ユーザー取得時の支払い状況を確認する', () {
    FetchCurrentUserUseCase target;
    MockAuthRepository mockAuthRepository;
    MockUserRepository mockUserRepository;
    MockPurchaseRepository mockPurchaseRepository;
    MockPurchaseUseCase mockPurchaseUseCase;

    User testUser;
//    LatestReceipt latestReceipt;

    setUpAll(() async {
      mockAuthRepository = MockAuthRepository();
      mockUserRepository = MockUserRepository();
      mockPurchaseRepository = MockPurchaseRepository();
      mockPurchaseUseCase = MockPurchaseUseCase();

      target = FetchCurrentUserUseCaseImpl(mockAuthRepository,
          mockUserRepository, mockPurchaseRepository, mockPurchaseUseCase);
    });

    test('プランのUnlimitedからProにダウングレード時、プロフィールのPaidPlanが更新されることを確認', () async {
      // given
      User testAuthUser = userTranslator.toModel(UserEntity(uid: "1"));
      testUser = userTranslator.toModel(UserEntity(
          uid: "1",
          name: "taro",
          email: "taro-mail",
          photoUrl: "url",
          themeId: "testId",
          paidPlanEntity: PaidPlanEntity(
              itemId: EnumUtil.getValueString(PaidType.Unlimited),
              transactionReceiptForIos: "need receipt",
              transactionReceiptForAndroid: "need receipt Android")));

      List<AppTheme> testThemeList = [
        themeTranslator.toModel(ThemeEntity(
            id: "testId", primary: "0xFF111111", accent: "0xFF222222"))
      ];

      LatestReceipt latestReceipt = LatestReceipt(
          latestReceipt: Receipt(productId: PaidType.Pro.toString()),
          transactionReceipt: null);

      // when
      // FIXME: Platform.isIOSはモックできない。macOSで実行すると、Platform.isIOSはfalseになる。
//      when(mockAppPlatform.isIOS()).thenAnswer((_) => true);

      when(mockAuthRepository.currentUser())
          .thenAnswer((_) => Future.value(testAuthUser));
      when(mockUserRepository.fetchUser(testAuthUser))
          .thenAnswer((_) => Future.value(testUser));
      when(mockUserRepository.fetchThemes())
          .thenAnswer((_) => Future.value(testThemeList));
      when(mockPurchaseRepository.validateReceipt(testUser))
          .thenAnswer((_) => Future.value(latestReceipt));
      when(mockPurchaseUseCase.updatePaidPlan(
              testUser,
              latestReceipt.latestReceipt.paidType,
              testUser.paidPlan,
              latestReceipt.latestReceipt.productId,
              latestReceipt.transactionReceipt,
              latestReceipt.transactionReceipt))
          .thenAnswer((_) => Future.value(testUser));

      // 事前確認
      expect(testUser.paidPlan.paidType, PaidType.Unlimited);
      expect(latestReceipt.latestReceipt.paidType, PaidType.Pro);

      User user = await target.execute();

      expect(user.paidPlan.transactionReceiptForIos, "need receipt");
      expect(
          user.paidPlan.transactionReceiptForAndroid, "need receipt Android");

      // then
      // 1回呼ばれることを確認
      verify(mockPurchaseUseCase.updatePaidPlan(
          testUser,
          latestReceipt.latestReceipt.paidType,
          testUser.paidPlan,
          latestReceipt.latestReceipt.productId,
          latestReceipt.transactionReceipt,
          latestReceipt.transactionReceipt));
    });

    test('プランの変更がない場合、PaidPlanを更新しないことを確認', () async {
      // given
      User testAuthUser = userTranslator.toModel(UserEntity(uid: "1"));
      testUser = userTranslator.toModel(UserEntity(
          uid: "1",
          name: "taro",
          email: "taro-mail",
          photoUrl: "url",
          themeId: "testId",
          paidPlanEntity: PaidPlanEntity(
              itemId: EnumUtil.getValueString(PaidType.Unlimited))));

      List<AppTheme> testThemeList = [
        themeTranslator.toModel(ThemeEntity(
            id: "testId", primary: "0xFF111111", accent: "0xFF222222"))
      ];

      LatestReceipt latestReceipt = LatestReceipt(
          latestReceipt: Receipt(productId: PaidType.Unlimited.toString()),
          transactionReceipt: null);

      // when
      when(mockAuthRepository.currentUser())
          .thenAnswer((_) => Future.value(testAuthUser));
      when(mockUserRepository.fetchUser(testAuthUser))
          .thenAnswer((_) => Future.value(testUser));
      when(mockUserRepository.fetchThemes())
          .thenAnswer((_) => Future.value(testThemeList));
      when(mockPurchaseRepository.validateReceipt(testUser))
          .thenAnswer((_) => Future.value(latestReceipt));
      when(mockPurchaseUseCase.updatePaidPlan(
              testUser,
              latestReceipt.latestReceipt.paidType,
              testUser.paidPlan,
              latestReceipt.latestReceipt.productId,
              latestReceipt.transactionReceipt,
              latestReceipt.transactionReceipt))
          .thenAnswer((_) => Future.value(testUser));

      // 事前確認
      expect(testUser.paidPlan.paidType, PaidType.Unlimited);
      expect(latestReceipt.latestReceipt.paidType, PaidType.Unlimited);

      await target.execute();

      // then
      // 1回呼ばれないことを確認
      verifyNever(mockPurchaseUseCase.updatePaidPlan(
          testUser,
          latestReceipt.latestReceipt.paidType,
          testUser.paidPlan,
          latestReceipt.latestReceipt.productId,
          latestReceipt.transactionReceipt,
          latestReceipt.transactionReceipt));
    });
  });
}
