import 'package:instantonnection/domain/model/PushMessage.dart';

class PushMessageEntity {
  PushMessageType messageType;
  String roomId;
  String title;
  String body;

  PushMessageEntity(this.messageType, this.roomId);

  PushMessageEntity.fromJSON(PushMessageType type, dynamic json) {
    this.messageType = type;
    this.roomId = json["roomId"];
    this.title = json["title"];
    this.body = json["body"];
  }
}
