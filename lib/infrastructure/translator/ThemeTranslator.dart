import 'package:instantonnection/domain/model/AppTheme.dart';
import 'package:instantonnection/infrastructure/entity/ThemeEntity.dart';
import 'package:instantonnection/infrastructure/util/ColorUtil.dart';

class ThemeTranslator {
  ThemeEntity toEntity(AppTheme appTheme) {
    return ThemeEntity(
        id: appTheme.id,
        primary: ColorUtil.toHexString(appTheme.primary),
        accent: ColorUtil.toHexString(appTheme.accent),
        name: appTheme.name);
  }

  List<AppTheme> toModelList(List<ThemeEntity> themeEntityList) {
    return themeEntityList.map((themeEntity) {
      return toModel(themeEntity);
    }).toList();
  }

  AppTheme toModel(ThemeEntity themeEntity) {
    return AppTheme(
        themeEntity.id ?? "theme0",
        themeEntity.primary != null
            ? ColorUtil.toColor(themeEntity.primary)
            : null,
        themeEntity.accent != null
            ? ColorUtil.toColor(themeEntity.accent)
            : null,
        name: themeEntity.name);
  }
}
