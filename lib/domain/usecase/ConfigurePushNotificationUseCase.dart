import 'dart:async';

import 'package:instantonnection/domain/model/PushMessage.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/repository/PushNotificationRepository.dart';
import 'package:instantonnection/domain/repository/UserRepository.dart';

/// Config
abstract class ConfigurePushNotificationUseCase {
  Stream<PushMessage> execute();

  Future<void> requestNotificationPermissions();

  Future<String> getToken();

  Future<String> registerToken(User user);
}

class ConfigurePushNotificationUseCaseImpl
    implements ConfigurePushNotificationUseCase {
  final PushNotificationRepository _pushNotificationRepository;
  final UserRepository _userRepository;

  ConfigurePushNotificationUseCaseImpl(
      this._pushNotificationRepository, this._userRepository);

  @override
  Stream<PushMessage> execute() {
    return _pushNotificationRepository.config();
  }

  @override
  Future<void> requestNotificationPermissions() {
    return _pushNotificationRepository.requestNotificationPermissions();
  }

  @override
  Future<String> getToken() => _pushNotificationRepository.getToken();

  @override
  Future<String> registerToken(User user) async {
    String token = await _pushNotificationRepository.getToken();
    return _userRepository.createNotificationToken(user, token);
  }
}
