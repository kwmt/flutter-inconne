import 'package:firebase_storage/firebase_storage.dart';

class UploadTask {
  StorageUploadTask uploadTask;
  StorageReference ref;
  int error;
  int bytesTransferred;
  int totalByteCount;
  Uri uploadSessionUri;
  StorageMetadata storageMetadata;

  UploadEventType type;

  UploadTask(this.ref, this.error, this.bytesTransferred, this.totalByteCount,
      this.uploadSessionUri, this.storageMetadata);

  String get uploadImageRate {
    return "${((bytesTransferred.toDouble() / totalByteCount.toDouble()) * 100).floor()}%";
  }

  bool get isCompleted {
    return (bytesTransferred / totalByteCount == 1);
  }

  UploadTask.fromSnapShot(
      StorageUploadTask uploadTask, StorageTaskSnapshot snapshot) {
    this.uploadTask = uploadTask;
//    this.ref = uploadTask.lastSnapshot.ref;
//    switch (event.type) {
//      case StorageTaskEventType.resume:
//        this.type = UploadEventType.resume;
//        break;
//      case StorageTaskEventType.pause:
//        this.type = UploadEventType.pause;
//        break;
//      case StorageTaskEventType.progress:
//        this.type = UploadEventType.progress;
//        break;
//      case StorageTaskEventType.success:
//        this.type = UploadEventType.success;
//        break;
//      case StorageTaskEventType.failure:
//        this.type = UploadEventType.failure;
//        break;
//    }
//
//    var snapshot = event.snapshot;
    this.ref = snapshot.ref;
    this.error = snapshot.error;
    this.bytesTransferred = snapshot.bytesTransferred;
    this.totalByteCount = snapshot.totalByteCount;
    this.uploadSessionUri = snapshot.uploadSessionUri;
    this.storageMetadata = snapshot.storageMetadata;
  }
}

enum UploadEventType {
  resume,
  progress,
  pause,
  success,
  failure,
}
