import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instantonnection/domain/model/AppTheme.dart';
import 'package:instantonnection/domain/model/BlockUser.dart';
import 'package:instantonnection/domain/model/PaidPlan.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/infrastructure/entity/UserEntity.dart';
import 'package:instantonnection/infrastructure/translator/ThemeTranslator.dart';
import 'package:instantonnection/infrastructure/translator/UserTranslator.dart';

void main() {
  group('UserTranslator 変換が変わらないことを確認', () {
    UserTranslator target;
    User testUser;

    setUpAll(() {
      target = UserTranslator();

      testUser = User(
          "1",
          "testUser",
          "testAddress",
          "url",
          AppTheme("testId", Color(0xFF111111), Color(0xFF222222),
              name: "testTheme"),
          PaidPlan(
              paidType: PaidType.Lite,
              itemId: "a.Lite",
              title: "testTitle",
              displayMessageCount: 100,
              uploadedFileCapacity: 100,
              createdRoomCount: 10,
              limitUploadFileCapacity: 200,
              isDisplayAd: false,
              description: "desc",
              transactionReceiptForIos: "testTran"),
          BlockUserList(List()));
    });

    test('toEntity ModelからEntityへの変換が変わらないことを確認', () {
      // when
      UserEntity userEntity = target.toEntity(testUser);

      // then
      expect(userEntity.uid, testUser.uid);
      expect(userEntity.name, testUser.name);
      expect(userEntity.email, testUser.email);
      expect(userEntity.photoUrl, testUser.photoUrl);
      expect(userEntity.themeId, testUser.theme.id);
      expect(userEntity.themeEntity,
          isNull); // FIXME: themeEntityにtranslateしなくていい？
      expect(userEntity.paidPlanEntity.itemId, testUser.paidPlan.itemId);
      expect(userEntity.paidPlanEntity.title, testUser.paidPlan.title);
      expect(userEntity.paidPlanEntity.displayMessageCount,
          testUser.paidPlan.displayMessageCount);
      expect(userEntity.paidPlanEntity.uploadedFileCapacity,
          testUser.paidPlan.uploadedFileCapacity);
      expect(userEntity.paidPlanEntity.createdRoomCount,
          testUser.paidPlan.createdRoomCount);
      expect(userEntity.paidPlanEntity.limitUploadFileCapacity,
          testUser.paidPlan.limitUploadFileCapacity);
      expect(
          userEntity.paidPlanEntity.isDisplayAd, testUser.paidPlan.isDisplayAd);
      expect(userEntity.paidPlanEntity.transactionReceiptForIos,
          testUser.paidPlan.transactionReceiptForIos);
      expect(userEntity.paidPlanEntity.createdAt, testUser.paidPlan.createdAt);
      expect(userEntity.paidPlanEntity.updatedAt, testUser.paidPlan.updatedAt);
    });

    test('toModel EntityからModelへの変換が変わらないことを確認', () {
      // given
      UserEntity testUserEntity = target.toEntity(testUser);
      AppTheme appTheme = AppTheme("testId", Color(0x111111), Color(0x222222),
          name: "testTheme");
      testUserEntity.themeEntity = ThemeTranslator().toEntity(appTheme);

      // when
      User actualUser = target.toModel(testUserEntity);

      // then
      expect(actualUser.uid, testUserEntity.uid);
      expect(actualUser.name, testUserEntity.name);
      expect(actualUser.email, testUserEntity.email);
      expect(actualUser.photoUrl, testUserEntity.photoUrl);
      expect(actualUser.theme.id, testUserEntity.themeId);
      expect(actualUser.theme.name, isNotNull);
      expect(actualUser.theme.name, testUserEntity.themeEntity.name);
      expect(actualUser.theme.id, testUserEntity.themeEntity.id);
      expect(actualUser.paidPlan.itemId, testUserEntity.paidPlanEntity.itemId);
      expect(actualUser.paidPlan.title, testUserEntity.paidPlanEntity.title);
      expect(actualUser.paidPlan.displayMessageCount,
          testUserEntity.paidPlanEntity.displayMessageCount);
      expect(actualUser.paidPlan.uploadedFileCapacity,
          testUserEntity.paidPlanEntity.uploadedFileCapacity);
      expect(actualUser.paidPlan.createdRoomCount,
          testUserEntity.paidPlanEntity.createdRoomCount);
      expect(actualUser.paidPlan.limitUploadFileCapacity,
          testUserEntity.paidPlanEntity.limitUploadFileCapacity);
      expect(actualUser.paidPlan.isDisplayAd,
          testUserEntity.paidPlanEntity.isDisplayAd);
      expect(actualUser.paidPlan.transactionReceiptForIos,
          testUserEntity.paidPlanEntity.transactionReceiptForIos);
      expect(actualUser.paidPlan.createdAt,
          testUserEntity.paidPlanEntity.createdAt);
      expect(actualUser.paidPlan.updatedAt,
          testUserEntity.paidPlanEntity.updatedAt);
    });
  });
}
