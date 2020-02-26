import 'package:instantonnection/infrastructure/datasource/util/DateTime.dart';
import 'package:instantonnection/infrastructure/entity/RoomUserEntity.dart';

class MessageEntity {
  String id;
  String fromUserId;
  String content;
  String imageUrl;

  RoomUserEntity roomUser;

  DateTime createdAt;
  DateTime updatedAt;

  MessageEntity(
      this.id, this.fromUserId, this.content, this.imageUrl, this.createdAt);

  MessageEntity.createContent(
      this.id, this.fromUserId, this.content, this.createdAt);

  MessageEntity.createImage(
      this.id, this.fromUserId, this.imageUrl, this.createdAt);

  MessageEntity.fromJSON(Map json, String id) {
    this.id = id;
    this.content = json['content'];
    this.imageUrl = json['image_url'];
    this.fromUserId = json['from_user_id'];
    this.createdAt = DateTimeUtil.parseTime(json['created_at']);
    this.updatedAt = DateTimeUtil.parseTime(json['updated_at']);
  }

  toObject() {
    return <String, dynamic>{
      'content': content,
      'image_url': imageUrl != null ? imageUrl.toString() : null,
      'from_user_id': fromUserId,
      'created_at': createdAt,
      'updated_at': DateTime.now(),
    };
  }
}
