import 'package:instantonnection/domain/model/BlockUser.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/repository/UserRepository.dart';

class BlockUserUseCase {
  final UserRepository _userRepository;

  BlockUserUseCase(this._userRepository);

  Future<void> removeBlockUser(User user, RoomUser roomUser) {
    return _userRepository.removeBlockUser(user, roomUser);
  }

  Future<BlockUserList> fetchBlockUsers(User user){
    return _userRepository.fetchBlockUsers(user);
  }
}
