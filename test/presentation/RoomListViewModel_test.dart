import 'package:flutter_test/flutter_test.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/usecase/ConfigurePushNotificationUseCase.dart';
import 'package:instantonnection/domain/usecase/FetchRoomListUseCase.dart';
import 'package:instantonnection/domain/usecase/LeaveRoomUseCase.dart';
import 'package:instantonnection/domain/usecase/UpdatePushNotificationSubscriptionUseCase.dart';
import 'package:instantonnection/presentation/room/RoomListViewModel.dart';
import 'package:mockito/mockito.dart';

class MockGFetchRoomListUseCase extends Mock implements FetchRoomListUseCase {}

class MockUpdatePushNotificationSubscriptionUseCase extends Mock
    implements UpdatePushNotificationSubscriptionUseCase {}

class MockConfigurePushNotificationUseCase extends Mock
    implements ConfigurePushNotificationUseCase {}

class MockLeaveRoomUseCase extends Mock implements LeaveRoomUseCase {}

class MockUser extends Mock implements User {}

void main() {
  group('RoomListScreen', () {
    RoomListViewModel target;
    FetchRoomListUseCase mockFetchRoomListUseCase;
    UpdatePushNotificationSubscriptionUseCase
        mockUpdatePushNotificationSubscriptionUseCase;
    ConfigurePushNotificationUseCase mockConfigurePushNotificationUseCase;
    LeaveRoomUseCase mockLeaveRoomUseCase;

    User mockUser;

    setUpAll(() {
      mockFetchRoomListUseCase = MockGFetchRoomListUseCase();
      mockUpdatePushNotificationSubscriptionUseCase =
          MockUpdatePushNotificationSubscriptionUseCase();
      mockConfigurePushNotificationUseCase =
          MockConfigurePushNotificationUseCase();
      mockLeaveRoomUseCase = MockLeaveRoomUseCase();
      target = RoomListViewModelImpl(
          mockFetchRoomListUseCase,
          mockUpdatePushNotificationSubscriptionUseCase,
          mockConfigurePushNotificationUseCase,
          mockLeaveRoomUseCase);

      mockUser = MockUser();
    });

    test('ユーザーが参加しているルーム一覧を取得することができる', () async {
      List<Room> roomList = List()..add(Room(name: "testRoom1"));

      when(mockFetchRoomListUseCase.execute(mockUser))
          .thenAnswer((_) => Future.value(roomList));

      target.init();

      target.fetchRoomList(mockUser);

      ViewState viewState2 = await target.viewState.first;
      expect(viewState2.viewType, ViewType.ROOMLIST);
    });
  });
}
