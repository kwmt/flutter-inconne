import 'package:instantonnection/domain/model/AppTheme.dart';
import 'package:instantonnection/domain/model/BlockUser.dart';
import 'package:instantonnection/domain/model/PaidPlan.dart';
import 'package:instantonnection/domain/model/Room.dart';

class User {
  String uid;
  String name;
  String email;
  String photoUrl;
  AppTheme theme;
  BlockUserList blockUserList;

  PaidPlan get paidPlan => _paidPlan ?? PaidPlan();

  set paidPlan(PaidPlan paidPlan) {
    _paidPlan = paidPlan;
  }

  PaidPlan _paidPlan;

  PaidType get paidType =>
      _paidPlan != null ? _paidPlan.paidType : PaidType.Free;

  User(
    this.uid,
    this.name,
    this.email,
    this.photoUrl,
    this.theme,
    this._paidPlan,
    this.blockUserList,
  );

  User.member(this.uid);

  User copy() {
    return User(
      this.uid,
      this.name,
      this.email,
      this.photoUrl,
      this.theme,
      this._paidPlan,
      this.blockUserList,
    );
  }

  RoomUser toRoomUser({bool isNotify = true, bool isMine = false}) {
    return RoomUser(
        userId: uid,
        name: name,
        photoUrl: photoUrl,
        isNotify: isNotify,
        isMine: isMine);
  }

  BlockUserList addBlockUser(RoomUser roomUser) {
    return blockUserList..addRoomUser(roomUser);
  }

  BlockUserList removeBlockUser(RoomUser roomUser) {
    return blockUserList..removeRoomUser(roomUser);
  }
}
