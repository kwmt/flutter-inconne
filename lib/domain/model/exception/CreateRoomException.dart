class CreateRoomException implements Exception {
  final String message;

  final CreateRoomExceptionType type;

  CreateRoomException({this.type, this.message});
}

enum CreateRoomExceptionType {
  /// Roomの上限を超えた場合
  QUOTE_EXCEEDED,

  /// 不明なエラー
  FAILED_ERROR
}
