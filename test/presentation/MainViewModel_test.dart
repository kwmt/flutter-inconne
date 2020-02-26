import 'package:flutter_test/flutter_test.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/usecase/FetchCurrentUserUseCase.dart';
import 'package:instantonnection/domain/usecase/GetIsOnboadingSavedUseCase.dart';
import 'package:instantonnection/presentation/MainViewModel.dart';
import 'package:mockito/mockito.dart';

class MockGetIsOnboadingSavedUseCase extends Mock
    implements GetIsOnboadingSavedUseCase {}

class MockFetchCurrentUserUseCase extends Mock
    implements FetchCurrentUserUseCase {}

class MockUser extends Mock implements User {}

void main() {
  group('初めてアプリを起動した時', () {
    MainViewModel target;
    GetIsOnboadingSavedUseCase mockGetIsOnboadingSavedUseCase;
    FetchCurrentUserUseCase mockFetchCurrentUserUseCase;
    User mockUser;

    setUpAll(() {
      mockGetIsOnboadingSavedUseCase = MockGetIsOnboadingSavedUseCase();
      mockFetchCurrentUserUseCase = MockFetchCurrentUserUseCase();
      target = MainViewModelImpl(
          mockGetIsOnboadingSavedUseCase, mockFetchCurrentUserUseCase);

      mockUser = MockUser();
    });

    test('オンボーディングを表示する事', () {
      when(mockGetIsOnboadingSavedUseCase.execute())
          .thenAnswer((_) => Future.value(false));

      target.init();

      expect(target.mainViewData,
          emits(MainViewData()..viewType = ViewType.ONBOARDING));
    });
  });
  group('2回目以降アプリを起動した時', () {
    MainViewModel target;
    GetIsOnboadingSavedUseCase mockGetIsOnboadingSavedUseCase;
    FetchCurrentUserUseCase mockFetchCurrentUserUseCase;
    User mockUser;

    setUpAll(() {
      mockGetIsOnboadingSavedUseCase = MockGetIsOnboadingSavedUseCase();
      mockFetchCurrentUserUseCase = MockFetchCurrentUserUseCase();
      target = MainViewModelImpl(
          mockGetIsOnboadingSavedUseCase, mockFetchCurrentUserUseCase);

      mockUser = MockUser();
    });

    test('ユーザーが登録されていない場合、サインイン画面を表示する事', () {
      when(mockGetIsOnboadingSavedUseCase.execute())
          .thenAnswer((_) => Future.value(true));

      when(mockFetchCurrentUserUseCase.execute())
          .thenAnswer((_) => Future.value(null));

      target.init();

      expect(target.mainViewData,
          emits(MainViewData()..viewType = ViewType.SIGNIN));
    });

    test('ユーザー登録されている場合、ホーム画面を表示する事', () {
      when(mockGetIsOnboadingSavedUseCase.execute())
          .thenAnswer((_) => Future.value(true));

      when(mockFetchCurrentUserUseCase.execute())
          .thenAnswer((_) => Future.value(mockUser));

      target.init();

      expect(
          target.mainViewData,
          emits(MainViewData()
            ..viewType = ViewType.ONBOARDING
            ..user = mockUser));
    });
    test('ユーザー取得に何らか失敗した場合、エラー画面を表示する事', () {
      when(mockGetIsOnboadingSavedUseCase.execute())
          .thenAnswer((_) => Future.value(true));

      when(mockFetchCurrentUserUseCase.execute()).thenThrow(Error());

      // FIXME: ExceptionUtilがstaticなのでテストできない・・・
      // 正確にはsendCrashlyticsメソッド内でFlutterCrashlytics()インスタンスを作っているのが問題。
//      target.init();
//      expect(target.viewType, emits(ViewType.ERROR));
    });
  });
}
