import 'dart:async';

import 'package:instantonnection/domain/model/Message.dart';
import 'package:instantonnection/domain/repository/LocalStorageRepository.dart';
import 'package:instantonnection/infrastructure/translator/MessageTranslator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceDatasource implements LocalStorageRepository {
  final MessageTranslator messageTranslator = MessageTranslator();

  @override
  Future<bool> saveMessage(Message message, String roomId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(
        _createMessageKey(roomId), messageTranslator.toEntity(message).content);
  }

  @override
  Future<String> getMessage(String roomId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_createMessageKey(roomId));
  }

  String _createMessageKey(String roomId) =>
      "${SharedPreferenceType.message.toString()}/$roomId";

  @override
  Future<bool> saveIsOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(SharedPreferenceType.onboarding.toString(), true);
  }

  @override
  Future<bool> isOnboadingSaved() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SharedPreferenceType.onboarding.toString()) ?? false;
  }
}

enum SharedPreferenceType { message, onboarding }
