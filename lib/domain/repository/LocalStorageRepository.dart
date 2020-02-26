import 'dart:async';

import 'package:instantonnection/domain/model/Message.dart';

abstract class LocalStorageRepository {
  Future<bool> saveMessage(Message message, String roomId);

  Future<String> getMessage(String roomId);

  Future<bool> saveIsOnboarding();

  Future<bool> isOnboadingSaved();
}
