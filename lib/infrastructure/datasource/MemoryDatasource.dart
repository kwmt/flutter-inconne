import 'package:instantonnection/infrastructure/entity/UserEntity.dart';

class MemoryDatasource {
  UserEntity _userEntity;

  void store(UserEntity userEntity) {
    this._userEntity = userEntity;
  }

  UserEntity fetch() {
    return _userEntity;
  }
}
