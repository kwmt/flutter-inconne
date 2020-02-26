import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:instantonnection/domain/model/AppTheme.dart';
import 'package:instantonnection/infrastructure/entity/ThemeEntity.dart';
import 'package:instantonnection/infrastructure/translator/ThemeTranslator.dart';
import 'package:instantonnection/infrastructure/util/ColorUtil.dart';

void main() {
  group('ThemeTranslator 変換が変わらないことを確認', () {
    ThemeTranslator target;
    AppTheme testAppTheme;

    setUpAll(() {
      target = ThemeTranslator();

      testAppTheme = AppTheme("testId", Color(0xFF111111), Color(0xFF222222),
          name: "testTheme");
    });

    test('toEntity ModelからEntityへの変換が変わらないことを確認', () {
      // when
      ThemeEntity themeEntity = target.toEntity(testAppTheme);

      // then
      expect(themeEntity.id, testAppTheme.id);
      expect(themeEntity.name, testAppTheme.name);
      expect(themeEntity.primary, ColorUtil.toHexString(testAppTheme.primary));
      expect(themeEntity.accent, ColorUtil.toHexString(testAppTheme.accent));
      expect(themeEntity.order, 1);
      expect(themeEntity.isDefault, isTrue);
    });

    test('toModel EntityからModelへの変換が変わらないことを確認', () {
      // given
      ThemeEntity themeEntity = target.toEntity(testAppTheme);
      // when
      AppTheme appTheme = target.toModel(themeEntity);


      // then
      expect(appTheme.id, themeEntity.id);
      expect(appTheme.name, themeEntity.name);
      expect(appTheme.primary, ColorUtil.toColor(themeEntity.primary));
      expect(appTheme.accent, ColorUtil.toColor(themeEntity.accent));
    });

  });
}
