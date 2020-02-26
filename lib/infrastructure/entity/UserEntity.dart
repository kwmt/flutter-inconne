import 'package:instantonnection/infrastructure/entity/BlockUserEntity.dart';
import 'package:instantonnection/infrastructure/entity/PaidPlanEntity.dart';
import 'package:instantonnection/infrastructure/entity/ThemeEntity.dart';

class UserEntity {
  String uid;
  String name;
  String email;
  String photoUrl;
  ThemeEntity themeEntity;
  String themeId;

  PaidPlanEntity paidPlanEntity;
  BlockUserListEntity blockUserListEntity;

  UserEntity({
    this.uid,
    this.name,
    this.email,
    this.photoUrl,
    this.themeId,
    this.paidPlanEntity,
    this.blockUserListEntity,
  });

  UserEntity.fromJSON(Map json) {
    this.uid = json['uid'];
    this.name = json['name'];
    this.email = json['email'];
    this.photoUrl = json['photo_url'];
//    this.themeEntity =
//        json['theme'] != null ? ThemeEntity.fromJSON(json['theme']) : null;
    this.themeId = json['theme_id'] != null ? json['theme_id'] : null;
    this.paidPlanEntity = json['paid_plan'] != null
        ? PaidPlanEntity.fromJSON(json['paid_plan'])
        : PaidPlanEntity();
    //this.blockUserListEntity = BlockUserListEntity.fromJSON(json);
  }

  toObject() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'photo_url': photoUrl,
//      'theme': themeEntity != null ? themeEntity.toObject() : null,
      'theme_id': themeId,
      'paid_plan': paidPlanEntity?.toObject(),
    };
  }
}
