import 'package:instantonnection/domain/model/BlockUser.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/infrastructure/entity/BlockUserEntity.dart';
import 'package:instantonnection/infrastructure/entity/PaidPlanEntity.dart';
import 'package:instantonnection/infrastructure/entity/ThemeEntity.dart';
import 'package:instantonnection/infrastructure/entity/UserEntity.dart';
import 'package:instantonnection/infrastructure/translator/PaidPlanTranslator.dart';
import 'package:instantonnection/infrastructure/translator/ThemeTranslator.dart';

class UserTranslator {
  final ThemeTranslator themeTranslator = ThemeTranslator();

  UserEntity toEntity(User user) {
    return UserEntity(
      uid: user.uid,
      name: user.name,
      email: user.email,
      photoUrl: user.photoUrl != null ? user.photoUrl.toString() : null,
      themeId: user.theme != null ? user.theme.id : "theme0",
      paidPlanEntity: user.paidPlan != null
          ? PaidPlanTranslator().toEntity(user.paidPlan)
          : PaidPlanEntity(),
      blockUserListEntity: user.blockUserList != null
          ? BlockUserTranslator().toEntity(user.blockUserList)
          : null,
    );
  }

  User toModel(UserEntity userEntity) {
    return User(
      userEntity.uid,
      userEntity.name,
      userEntity.email,
      userEntity.photoUrl,
      userEntity.themeEntity != null
          ? themeTranslator.toModel(userEntity.themeEntity)
          : userEntity.themeId != null
              ? themeTranslator.toModel(ThemeEntity(id: userEntity.themeId))
              : themeTranslator.toModel(ThemeEntity()),
      userEntity.paidPlanEntity != null
          ? PaidPlanTranslator().toModel(userEntity.paidPlanEntity)
          : null,
      userEntity.blockUserListEntity != null
          ? BlockUserTranslator().toModel(userEntity.blockUserListEntity)
          : BlockUserList(List()),
    );
  }

  List<User> toModelList(List<UserEntity> userEntityList) {
    return userEntityList.map((userEntity) {
      return toModel(userEntity);
    }).toList();
  }
}

class BlockUserTranslator {
  BlockUserList toModel(BlockUserListEntity entities) {
    if (entities.blockUsers == null) {
      return BlockUserList(List<RoomUser>());
    }
    return BlockUserList(entities.blockUsers.map((entity) {
      return RoomUser(
          userId: entity.uid, name: entity.name, photoUrl: entity.photoUrl);
    }).toList());
  }

  BlockUserListEntity toEntity(BlockUserList model) {
    return BlockUserListEntity(
        blockUsers: model.blockUsers.map((user) {
      return BlockUserEntity(
          uid: user.userId, name: user.name, photoUrl: user.photoUrl);
    }).toList());
  }
}
