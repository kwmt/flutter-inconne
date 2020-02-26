class PushMessage {
  PushMessageType pushMessageType;
  String roomId;
  String title;
  String body;

  PushMessage(this.pushMessageType, this.roomId, this.title, this.body);
}

enum PushMessageType {
  Message,
  Launch,
  Resume,
}
