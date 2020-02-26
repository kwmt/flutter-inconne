import 'dart:async';
import 'dart:io';

import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/UploadImageType.dart';
import 'package:instantonnection/domain/model/UploadTask.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/model/exception/UploadImageException.dart';
import 'package:instantonnection/domain/repository/StorageRepository.dart';
import 'package:instantonnection/domain/repository/UserRepository.dart';

/// 画像をアップロードする
abstract class UploadImageUseCase {
  /// Roomのメインイメージをアップロードする
  /// @param room どの[room]に格納するか。
  Future<UploadTask> room(File file, Room room, User user);

  /// メッセージとして画像をアップロードする
  /// @param room どの[room]に格納するか。
  Future<UploadTask> message(File file, Room room, User user);

  /// ユーザーのプロフィール画像をアップロードする
  /// @param user だれの[user]の写真を格納するか
  Future<UploadTask> profile(File file, User user);
}

class UploadImageUseCaseImpl implements UploadImageUseCase {
  final StorageRepository _storageRepository;
  final UserRepository _userRepository;

  UploadImageUseCaseImpl(this._storageRepository, this._userRepository);

  @override
  Future<UploadTask> message(File file, Room room, User user) async {
    File compressedFile = await _storageRepository.compressImage(file);
    if (!user.paidPlan.canUploadFile) {
      throw UploadImageException(type: UploadImageExceptionType.QUOTE_EXCEEDED);
    }
    return _storageRepository
        .uploadImage(UploadImageType.Message, compressedFile,
            room: room, user: user)
        .then((uploadTask) => _updateFileCapacity(user, uploadTask));
  }

  @override
  Future<UploadTask> room(File file, Room room, User user) async {
    File compressedFile = await _storageRepository.compressImage(file);
    if (!user.paidPlan.canUploadFile) {
      throw UploadImageException(type: UploadImageExceptionType.QUOTE_EXCEEDED);
    }
    return _storageRepository
        .uploadImage(UploadImageType.Room, compressedFile, room: room)
        .then((uploadTask) => _updateFileCapacity(user, uploadTask));
    // TODO: ルーム画像はRoomユーザーが編集できるので、File容量を加算するのは、微妙かも？
    // ただ、画像上げすぎ防止には役に立つか？もう少し考える。
  }

  @override
  Future<UploadTask> profile(File file, User user) async {
    File compressedFile = await _storageRepository.compressImage(file);
    if (!user.paidPlan.canUploadFile) {
      throw UploadImageException(type: UploadImageExceptionType.QUOTE_EXCEEDED);
    }
    return _storageRepository
        .uploadImage(UploadImageType.Profile, compressedFile, user: user)
        .then((uploadTask) => _updateFileCapacity(user, uploadTask));
  }

  Future<UploadTask> _updateFileCapacity(
      User user, UploadTask uploadTask) async {
    user.paidPlan.uploadedFileCapacity += uploadTask.totalByteCount;
    _userRepository.update(user);
    return uploadTask;
  }
}
