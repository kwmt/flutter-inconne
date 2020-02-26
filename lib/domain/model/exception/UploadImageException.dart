class UploadImageException implements Exception {
  final String message;

  final UploadImageExceptionType type;

  UploadImageException({this.type, this.message});
}

enum UploadImageExceptionType {
  /// アップロード可能容量上限を超えている場合
  QUOTE_EXCEEDED,

  /// 不明なエラー
  UNKNOWN_ERROR,

  CANCELED,
}
