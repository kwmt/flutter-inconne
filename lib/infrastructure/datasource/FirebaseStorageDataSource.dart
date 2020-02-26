import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/UploadImageType.dart';
import 'package:instantonnection/domain/model/UploadTask.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/model/exception/UploadImageException.dart';
import 'package:instantonnection/domain/repository/StorageRepository.dart';
import 'package:instantonnection/infrastructure/datasource/util/Image.dart';
import 'package:instantonnection/infrastructure/entity/RoomEntity.dart';
import 'package:instantonnection/infrastructure/entity/UserEntity.dart';
import 'package:instantonnection/infrastructure/translator/RoomTranslator.dart';
import 'package:instantonnection/infrastructure/translator/UserTranslator.dart';
import 'package:path/path.dart';

class FirebaseStorageDataSource implements StorageRepository {
  final FirebaseStorage storage;

  FirebaseStorageDataSource(this.storage);

  final UserTranslator userTranslator = UserTranslator();
  final RoomTranslator roomTranslator = RoomTranslator();

  @override
  Future<File> compressImage(File file) => Image.compress(file);

  /// 画像をFirebase Storageにアップロードします。
  ///
  /// @param room どの[room]に格納するか。
  /// @param user だれの[user]の写真を格納するか
  ///
  /// roomID/image_file_name.jpg →これによりRoomごとに写真一覧を表示できる。
  /// userID/image_file_name.jpg→これにより、Userごとの写真一覧を表示できる。
  /// roomもuserも指定がなければ、
  /// images/image_file_name.jpgのように格納します。これは使わないかも。
  @override
  Future<UploadTask> uploadImage(UploadImageType type, File file,
      {Room room, User user}) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    String subDirectoryName = 'images/';
    switch (type) {
      case UploadImageType.Message:
        RoomEntity roomEntity = roomTranslator.toEntity(room);
        UserEntity userEntity = userTranslator.toEntity(user);
        subDirectoryName += "rooms/${roomEntity.id}/messages/${userEntity.uid}";
        break;
      case UploadImageType.Room:
//        RoomEntity roomEntity = roomTranslator.toEntity(room);
        subDirectoryName += "rooms/${room.id}";
        break;
      case UploadImageType.Profile:
        UserEntity userEntity = userTranslator.toEntity(user);
        subDirectoryName += "users/${userEntity.uid}";
        break;
    }

    final StorageReference ref = storage
        .ref()
        .child(subDirectoryName)
        .child('${timestamp}_${basename(file.path)}');

    final StorageUploadTask uploadTask = ref.putFile(
        file,
        StorageMetadata(
          contentType: "image/jpeg", // 圧縮されたファイルがjpgになっているので。
        ));
    StorageTaskSnapshot snapshot = await uploadTask.onComplete;
    if (snapshot.error == null) {
      return UploadTask.fromSnapShot(uploadTask, snapshot);
    }
    print(snapshot.error);
    switch (snapshot.error) {
      case StorageError.unknown:
      case StorageError.objectNotFound:
      case StorageError.bucketNotFound:
      case StorageError.projectNotFound:
      case StorageError.quotaExceeded:
      case StorageError.notAuthenticated:
      case StorageError.notAuthorized:
      case StorageError.retryLimitExceeded:
      case StorageError.invalidChecksum:
        throw UploadImageException(
            type: UploadImageExceptionType.UNKNOWN_ERROR);
      case StorageError.canceled:
        throw UploadImageException(type: UploadImageExceptionType.CANCELED);
    }

//    return Future.value(UploadTask.fromSnapShot(uploadTask, null));

    // TODO: Stream async* とyield*の関係を理解できていないが、動いてしまった。。。いつかちゃんと調べる!
//    yield* uploadTask.events.map((event) {
//      return UploadTask.fromSnapShot(uploadTask, event);
//    });
  }
}
