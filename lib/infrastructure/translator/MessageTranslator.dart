import 'package:instantonnection/domain/model/Message.dart';
import 'package:instantonnection/infrastructure/entity/MessageEntity.dart';
import 'package:instantonnection/infrastructure/translator/RoomUserTranslator.dart';
import 'package:instantonnection/infrastructure/translator/UserTranslator.dart';

class MessageTranslator {
  UserTranslator userTranslator = UserTranslator();
  RoomUserTranslator _roomUserTranslator = RoomUserTranslator();

  MessageEntity toEntity(Message message) {
    if (message.content != null && message.downloadImageUrl == null) {
      return MessageEntity(message.id, message.roomUser.userId, message.content,
          message.downloadImageUrl, message.createdAt);
    }
    if (message.content != null) {
      return MessageEntity.createContent(message.id, message.roomUser.userId,
          message.content, message.createdAt);
    }
    if (message.downloadImageUrl != null) {
      return MessageEntity.createImage(message.id, message.roomUser.userId,
          message.downloadImageUrl, message.createdAt);
    }
    throw ArgumentError("messsageの内容contentかimagefileを指定してください。");
  }

  Message toModel(MessageEntity messageEntity) {
    return Message(
        messageEntity.id,
        messageEntity.content,
        messageEntity.imageUrl,
        _roomUserTranslator.toModel(messageEntity.roomUser),
        messageEntity.createdAt);
  }
}
