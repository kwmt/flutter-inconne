import 'dart:async';
import 'dart:io';

import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/UploadImageType.dart';
import 'package:instantonnection/domain/model/UploadTask.dart';
import 'package:instantonnection/domain/model/User.dart';

abstract class StorageRepository {
  Future<File> compressImage(File file);

  Future<UploadTask> uploadImage(UploadImageType type, File file,
      {Room room, User user});
}
