import 'package:instantonnection/domain/model/PushMessage.dart';
import 'package:instantonnection/infrastructure/entity/PushMessageEntity.dart';

class PushMessageTranslator {
  PushMessage toModel(PushMessageEntity entity) {
    return PushMessage(
        entity.messageType, entity.roomId, entity.title, entity.body);
  }
}
