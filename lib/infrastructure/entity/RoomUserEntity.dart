import 'package:instantonnection/infrastructure/datasource/util/DateTime.dart';

/// Room情報
///
class RoomUserEntity {
  String userId;
  String name;
  String photoUrl;
  bool isNotify;
  DateTime lastReadTime;

  // アプリ内で知りたいだけので、DBに保存しない
  bool isMine = false;

  RoomUserEntity(
      {this.userId, this.name, this.photoUrl, this.isNotify, this.isMine});

  RoomUserEntity.fromJSON(String userId, Map json) {
    this.userId = userId;
    this.name = json['name'];
    this.photoUrl = json['photo_url'];
    this.isNotify =
        json['is_notify']?.toString()?.toLowerCase() == 'true' ?? false;
    this.lastReadTime = json['last_read_time'] != null ? DateTimeUtil.parseTime(json['last_read_time']) : null;
  }

  toObject() {
    return <String, dynamic>{
      'userId': userId,
      'name': name,
      'photo_url': photoUrl,
      'is_notify': isNotify,
      'last_read_time': lastReadTime,
    };
  }
}
