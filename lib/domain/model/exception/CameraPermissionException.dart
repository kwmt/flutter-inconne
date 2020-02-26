class CameraPermissionException implements Exception {
  final String message;

  final Exception error;

  CameraPermissionException(this.error, {this.message});
}
