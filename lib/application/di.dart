import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:instantonnection/application/AppConfig.dart';
import 'package:instantonnection/domain/repository/AdsRepository.dart';
import 'package:instantonnection/domain/repository/AuthRepository.dart';
import 'package:instantonnection/domain/repository/LocalStorageRepository.dart';
import 'package:instantonnection/domain/repository/PurchaseRepository.dart';
import 'package:instantonnection/domain/repository/PushNotificationRepository.dart';
import 'package:instantonnection/domain/repository/RoomRepository.dart';
import 'package:instantonnection/domain/repository/StorageRepository.dart';
import 'package:instantonnection/domain/repository/UserRepository.dart';
import 'package:instantonnection/domain/usecase/AddMemberToRoomUseCase.dart';
import 'package:instantonnection/domain/usecase/AdsUseCase.dart';
import 'package:instantonnection/domain/usecase/BlockUserUseCase.dart';
import 'package:instantonnection/domain/usecase/ConfigurePushNotificationUseCase.dart';
import 'package:instantonnection/domain/usecase/CreateNewMessageUseCase.dart';
import 'package:instantonnection/domain/usecase/CreateNewRoomUseCase.dart';
import 'package:instantonnection/domain/usecase/CreateNewUserUseCase.dart';
import 'package:instantonnection/domain/usecase/FetchChatListOfRoomUseCase.dart';
import 'package:instantonnection/domain/usecase/FetchCurrentUserUseCase.dart';
import 'package:instantonnection/domain/usecase/FetchRoomListUseCase.dart';
import 'package:instantonnection/domain/usecase/FetchRoomUseCase.dart';
import 'package:instantonnection/domain/usecase/FetchThemeListUseCase.dart';
import 'package:instantonnection/domain/usecase/GetIsOnboadingSavedUseCase.dart';
import 'package:instantonnection/domain/usecase/GetMessageUseCase.dart';
import 'package:instantonnection/domain/usecase/LeaveRoomUseCase.dart';
import 'package:instantonnection/domain/usecase/LogoutUseCase.dart';
import 'package:instantonnection/domain/usecase/PurchaseUseCase.dart';
import 'package:instantonnection/domain/usecase/ReportUseCase.dart';
import 'package:instantonnection/domain/usecase/SaveIsOnboadingReadUseCase.dart';
import 'package:instantonnection/domain/usecase/SaveMessageUseCase.dart';
import 'package:instantonnection/domain/usecase/SignInUseCase.dart';
import 'package:instantonnection/domain/usecase/UpdatePushNotificationSubscriptionUseCase.dart';
import 'package:instantonnection/domain/usecase/UpdateRoomUseCase.dart';
import 'package:instantonnection/domain/usecase/UpdateUserProfileUseCase.dart';
import 'package:instantonnection/domain/usecase/UploadImageUseCase.dart';
import 'package:instantonnection/domain/usecase/WatchSingInStateUseCase.dart';
import 'package:instantonnection/infrastructure/datasource/AdMobDatasource.dart';
import 'package:instantonnection/infrastructure/datasource/FirebaseAuthDatasource.dart';
import 'package:instantonnection/infrastructure/datasource/FirebaseMessagingDatasource.dart';
import 'package:instantonnection/infrastructure/datasource/FirebaseStorageDataSource.dart';
import 'package:instantonnection/infrastructure/datasource/FirestoreDatasource.dart';
import 'package:instantonnection/infrastructure/datasource/PlayAppStoreDatasource.dart';
import 'package:instantonnection/infrastructure/datasource/SharedPreferenceDatasource.dart';
import 'package:instantonnection/presentation/MainScreen.dart';
import 'package:instantonnection/presentation/MainViewModel.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';
import 'package:instantonnection/presentation/home/HomeSreen.dart';
import 'package:instantonnection/presentation/onboarding/OnboardingScreen.dart';
import 'package:instantonnection/presentation/photo/PreviewPhotoScreen.dart';
import 'package:instantonnection/presentation/photo/ScalableImageScreen.dart';
import 'package:instantonnection/presentation/profile/BlockUserListScreen.dart';
import 'package:instantonnection/presentation/profile/BlockUserListViewModel.dart';
import 'package:instantonnection/presentation/profile/EditThemeScreen.dart';
import 'package:instantonnection/presentation/profile/ProfileEditScreen.dart';
import 'package:instantonnection/presentation/profile/ProfileScreen.dart';
import 'package:instantonnection/presentation/purchase/PurchaseScreen.dart';
import 'package:instantonnection/presentation/report/ReportScreen.dart';
import 'package:instantonnection/presentation/room/CreateRoomScreen.dart';
import 'package:instantonnection/presentation/room/DisplayQrCodeScreen.dart';
import 'package:instantonnection/presentation/room/EditRoomScreen.dart';
import 'package:instantonnection/presentation/room/JoinRoomReader.dart';
import 'package:instantonnection/presentation/room/RoomFooterWidget.dart';
import 'package:instantonnection/presentation/room/RoomListScreen.dart';
import 'package:instantonnection/presentation/room/RoomListViewModel.dart';
import 'package:instantonnection/presentation/room/RoomScreen.dart';
import 'package:instantonnection/presentation/room/RoomSettingScreen.dart';
import 'package:instantonnection/presentation/signin/SigninScreen.dart';
import 'package:instantonnection/presentation/user/UserProfileScreen.dart';

class DependencyInjection {
  Future<void> initialize(AppConfig appConfig) async {
    final FirebaseApp app = await FirebaseApp.configure(
      name: appConfig.googleProjectId,
      options: FirebaseOptions(
        googleAppID: appConfig.googleAppID,
        apiKey: appConfig.googleApiKey,
        projectID: appConfig.googleProjectId,
      ),
    );
//        .timeout(Duration(seconds: 5), onTimeout: (){
//      throw TimeoutException("タイムアウトしました");
//    })

    final injector = Injector.getInjector();

//    injector.map<FirebaseApp>((i) => app, isSingleton: true);
    injector.map<Firestore>((i) => Firestore(), isSingleton: true);
    injector.map<FirebaseStorage>(
        (i) => FirebaseStorage(
            // https://stackoverflow.com/a/37802279
            app: app,
            storageBucket: appConfig.firebaseStorageBucket)
          ..setMaxUploadRetryTimeMillis(2000),
        isSingleton: true);

    // Analytics
    injector.map<FirebaseAnalytics>((i) => FirebaseAnalytics(),
        isSingleton: true);
    injector.map<FirebaseAnalyticsObserver>(
        (i) => FirebaseAnalyticsObserver(analytics: i.get<FirebaseAnalytics>()),
        isSingleton: true);

    // Datasource
    injector.map<FirestoreDatasource>(
        (i) => FirestoreDatasource(i.get<Firestore>()),
        isSingleton: true);
    injector.map<FirebaseAuthDatasource>((i) => FirebaseAuthDatasource(),
        isSingleton: true);
    injector.map<FirebaseStorageDataSource>(
        (i) => FirebaseStorageDataSource(i.get<FirebaseStorage>()),
        isSingleton: true);
    injector.map<FirebaseMessagingDatasource>(
        (i) => FirebaseMessagingDatasource(),
        isSingleton: true);
    injector.map<SharedPreferenceDatasource>(
        (i) => SharedPreferenceDatasource(),
        isSingleton: true);
    injector.map<PlayAppStoreDatasource>(
        (i) => PlayAppStoreDatasource(appConfig),
        isSingleton: true);
    injector.map<AdMobDataSource>((i) => AdMobDataSource(appConfig),
        isSingleton: true);

    // Repository
    injector.map<RoomRepository>((i) => i.get<FirestoreDatasource>(),
        isSingleton: true);
    injector.map<UserRepository>((i) => i.get<FirestoreDatasource>(),
        isSingleton: true);
    injector.map<PushNotificationRepository>(
        (i) => i.get<FirebaseMessagingDatasource>(),
        isSingleton: true);
    injector.map<AuthRepository>((i) => i.get<FirebaseAuthDatasource>(),
        isSingleton: true);
    injector.map<StorageRepository>((i) => i.get<FirebaseStorageDataSource>(),
        isSingleton: true);
    injector.map<LocalStorageRepository>(
        (i) => i.get<SharedPreferenceDatasource>(),
        isSingleton: true);
    injector.map<PurchaseRepository>((i) => i.get<PlayAppStoreDatasource>(),
        isSingleton: true);
    injector.map<AdsRepository>((i) => i.get<AdMobDataSource>(),
        isSingleton: true);

    // Navigator
    injector.map<AppNavigator>((i) => AppNavigatorImpl(), isSingleton: true);

    // UseCase
    injector.map<CreateNewUserUseCase>(
        (i) => CreateNewUserUseCaseImpl(i.get<UserRepository>()),
        isSingleton: true);
    injector.map<CreateNewRoomUseCase>(
        (i) => CreateNewRoomUseCaseImpl(
            i.get<RoomRepository>(),
            i.get<UserRepository>(),
            i.get<UploadImageUseCase>(),
            i.get<UpdatePushNotificationSubscriptionUseCase>()),
        isSingleton: true);
    injector.map<UpdateRoomUseCase>(
        (i) => UpdateRoomUseCaseImpl(i.get<RoomRepository>()),
        isSingleton: true);
    injector.map<AddMemberToRoomUseCase>(
        (i) => AddMemberToRoomUseCaseImpl(i.get<RoomRepository>()),
        isSingleton: true);
    injector.map<UpdateUserProfileUseCase>(
        (i) => UpdateUserProfileUseCaseImpl(i.get<AuthRepository>(),
            i.get<UserRepository>(), i.get<RoomRepository>()),
        isSingleton: true);
    injector.map<FetchRoomListUseCase>(
        (i) => FetchRoomListUseCaseImpl(i.get<RoomRepository>()),
        isSingleton: true);
    injector.map<FetchRoomUseCase>(
        (i) => FetchRoomUseCaseImpl(i.get<RoomRepository>()),
        isSingleton: true);
    injector.map<FetchChatListOfRoomUseCase>(
        (i) => FetchChatListOfRoomUseCaseImpl(i.get<RoomRepository>()),
        isSingleton: true);
    injector.map<FetchCurrentUserUseCase>(
        (i) => FetchCurrentUserUseCaseImpl(
            i.get<AuthRepository>(),
            i.get<UserRepository>(),
            i.get<PurchaseRepository>(),
            i.get<PurchaseUseCase>()),
        isSingleton: true);
    injector.map<WatchSingInStateUseCase>(
        (i) => WatchSingInStateUseCaseImpl(
            i.get<AuthRepository>(), i.get<FetchCurrentUserUseCase>()),
        isSingleton: true);
    injector.map<CreateNewMessageUseCase>(
        (i) => CreateNewMessageUseCaseImpl(i.get<RoomRepository>()),
        isSingleton: true);
    injector.map<UploadImageUseCase>(
        (i) => UploadImageUseCaseImpl(
            i.get<FirebaseStorageDataSource>(), i.get<FirestoreDatasource>()),
        isSingleton: true);
    injector.map<SignInUseCase>(
        (i) => SignInUseCaseImpl(i.get<FirebaseAuthDatasource>()),
        isSingleton: true);
    injector.map<LogoutUseCase>(
        (i) => LogoutUseCaseImpl(i.get<FirebaseAuthDatasource>()),
        isSingleton: true);
    injector.map<ConfigurePushNotificationUseCase>(
        (i) => ConfigurePushNotificationUseCaseImpl(
            i.get<PushNotificationRepository>(), i.get<UserRepository>()),
        isSingleton: true);
    injector.map<UpdatePushNotificationSubscriptionUseCase>(
        (i) => UpdatePushNotificationSubscriptionUseCaseImpl(
            i.get<PushNotificationRepository>(), i.get<RoomRepository>()),
        isSingleton: true);
    injector.map<FetchThemeListUseCase>(
        (i) => FetchThemeListUseCaseImpl(i.get<UserRepository>()),
        isSingleton: true);
    injector.map<PurchaseUseCase>(
        (i) => PurchaseUseCaseImpl(
            i.get<PurchaseRepository>(), i.get<UpdateUserProfileUseCase>()),
        isSingleton: true);
    injector.map<SaveMessageUseCase>(
        (i) => SaveMessageUseCaseImpl(i.get<LocalStorageRepository>()),
        isSingleton: true);
    injector.map<GetMessageUseCase>(
        (i) => GetMessageUseCaseImpl(i.get<LocalStorageRepository>()),
        isSingleton: true);
    injector.map<SaveIsOnboadingReadUseCase>(
        (i) => SaveIsOnboadingReadUseCaseImpl(i.get<LocalStorageRepository>()),
        isSingleton: true);
    injector.map<GetIsOnboadingSavedUseCase>(
        (i) => GetIsOnboadingSavedUseCaseImpl(i.get<LocalStorageRepository>()),
        isSingleton: true);
    injector.map<AdsUseCase>((i) => AdsUseCaseImpl(i.get<AdsRepository>()),
        isSingleton: true);

    injector.mapWithParams<JoinRoomReader>((i, p) => JoinRoomReader(
        i.get<AppNavigator>(),
        i.get<AddMemberToRoomUseCase>(),
        i.get<UpdatePushNotificationSubscriptionUseCase>()));

    injector.map<LeaveRoomUseCase>(
        (i) => LeaveRoomUseCaseImpl(
            i.get<RoomRepository>(), i.get<PushNotificationRepository>()),
        isSingleton: true);
    injector.map<ReportUseCase>(
        (i) => ReportRoomUseCaseImpl(i.get<RoomRepository>()),
        isSingleton: true);

    injector.map<BlockUserUseCase>(
        (i) => BlockUserUseCase(i.get<UserRepository>()),
        isSingleton: true);

    // ViewModel
    injector.mapWithParams<BlockUserListViewModel>((i, p) =>
        BlockUserListViewModel(p["user"], i.get<BlockUserUseCase>(),
            i.get<UpdatePushNotificationSubscriptionUseCase>()));

    // Widget(Screen)
    injector.map<MainScreen>((i) {
      MainViewModel mainViewModel = MainViewModelImpl(
          i.get<GetIsOnboadingSavedUseCase>(),
          i.get<FetchCurrentUserUseCase>());
      return MainScreen(mainViewModel, i.get<AppNavigator>());
    });

    injector.map<OnboardingScreen>((i) => OnboardingScreen(
          saveIsOnboadingReadUseCase: i.get<SaveIsOnboadingReadUseCase>(),
          appNavigator: i.get<AppNavigator>(),
        ));

    injector.mapWithParams<HomeScreen>((i, p) => HomeScreen(
          p["user"],
          i.get<AppNavigator>(),
        ));

    injector.mapWithParams<EditRoomScreen>((i, p) => EditRoomScreen(
          room: p["room"],
          user: p["user"],
          updateRoomUseCase: i.get<UpdateRoomUseCase>(),
          uploadImageUseCase: i.get<UploadImageUseCase>(),
          appNavigator: i.get<AppNavigator>(),
        ));

    injector.map<MySignInScreen>((i) => MySignInScreen(
          i.get<CreateNewUserUseCase>(),
          i.get<WatchSingInStateUseCase>(),
          i.get<SignInUseCase>(),
          i.get<AppNavigator>(),
        ));

    injector.mapWithParams<RoomListScreen>((i, p) => RoomListScreen(
          p["user"],
          RoomListViewModelImpl(
              i.get<FetchRoomListUseCase>(),
              i.get<UpdatePushNotificationSubscriptionUseCase>(),
              i.get<ConfigurePushNotificationUseCase>(),
              i.get<LeaveRoomUseCase>()),
          i.get<JoinRoomReader>(),
          i.get<AppNavigator>(),
        ));

    injector.mapWithParams<RoomScreen>((i, p) => RoomScreen(
          p["room"],
          p["user"],
          i.get<FetchChatListOfRoomUseCase>(),
          i.get<LeaveRoomUseCase>(),
//          i.get<CreateNewMessageUseCase>(),
//          i.get<UploadImageUseCase>(),
//          i.get<SaveMessageUseCase>(),
//          i.get<GetMessageUseCase>(),
          i.get<AppNavigator>(),
        ));

    injector.mapWithParams<RoomFooterWidget>((i, p) => RoomFooterWidget(
          p["room"],
          p["user"],
          i.get<CreateNewMessageUseCase>(),
          i.get<UploadImageUseCase>(),
          i.get<SaveMessageUseCase>(),
          i.get<GetMessageUseCase>(),
          i.get<AppNavigator>(),
          onMessageSendCompletionCallback: p["onMessageSendCompletionCallback"],
          onPreUploadImageCallback: p["onPreUploadImageCallback"],
          onPostUploadImageCallback: p["onPostUploadImageCallback"],
        ));

    injector.mapWithParams<CreateRoomScreen>((i, p) => CreateRoomScreen(
          p["user"],
          i.get<CreateNewRoomUseCase>(),
          i.get<AppNavigator>(),
          room: p["room"],
        ));

    injector.mapWithParams<RoomSettingScreen>((i, p) => RoomSettingScreen(
          room: p["room"],
          user: p["user"],
          appNavigator: i.get<AppNavigator>(),
          adsUseCase: i.get<AdsUseCase>(),
        ));

    injector.mapWithParams<ProfileScreen>((i, p) => ProfileScreen(
        p["user"],
        i.get<LogoutUseCase>(),
        i.get<FetchRoomListUseCase>(),
        i.get<AdsUseCase>(),
        i.get<AppNavigator>()));

    injector.mapWithParams<EditThemeScreen>((i, p) => EditThemeScreen(
          user: p["user"],
          appNavigator: i.get<AppNavigator>(),
          fetchThemeListUseCase: i.get<FetchThemeListUseCase>(),
          updateUserProfileUseCase: i.get<UpdateUserProfileUseCase>(),
        ));

    injector.mapWithParams<BlockUserListScreen>((i, p) => BlockUserListScreen(
          appNavigator: i.get<AppNavigator>(),
          viewModel: i.get<BlockUserListViewModel>(
              additionalParameters: {"user": p["user"]}),
//          fetchThemeListUseCase: i.get<FetchThemeListUseCase>(),
//          updateUserProfileUseCase: i.get<UpdateUserProfileUseCase>(),
        ));

    injector.mapWithParams<ProfileEditScreen>((i, p) => ProfileEditScreen(
        p["user"],
        p["rooms"],
        i.get<UpdateUserProfileUseCase>(),
        i.get<UploadImageUseCase>(),
        i.get<AppNavigator>()));

    injector.mapWithParams<PreviewPhotoScreen>(
        (i, p) => PreviewPhotoScreen(p["imageFile"]));

    injector.mapWithParams<ScalableImageScreen>((i, p) => ScalableImageScreen(
          imageUrls: p["imageUrls"],
          position: p["position"],
        ));

    injector.mapWithParams<DisplayQrCodeScreen>((i, p) => DisplayQrCodeScreen(
          p["qrCodeData"],
        ));

    injector.mapWithParams<PurchaseScreen>((i, p) => PurchaseScreen(
          user: p["user"],
          isForSubscription: p["isForSubscription"],
          purchaseUseCase: i.get<PurchaseUseCase>(),
          updateUserProfileUseCase: i.get<UpdateUserProfileUseCase>(),
          appNavigator: i.get<AppNavigator>(),
        ));

    injector.mapWithParams<ReportScreen>((i, p) => ReportScreen(
          user: p["user"],
          room: p["room"],
          message: p["message"],
          reportRoomUseCase: i.get<ReportUseCase>(),
          appNavigator: i.get<AppNavigator>(),
        ));

    injector.mapWithParams<UserProfileScreen>((i, p) => UserProfileScreen(
          viewModel: UserProfileViewModel(
              p["user"],
              p["roomUser"],
              p["room"],
              i.get<RoomRepository>(),
              i.get<UserRepository>(),
              i.get<UpdatePushNotificationSubscriptionUseCase>()),
          appNavigator: i.get<AppNavigator>(),
        ));

    return Future.value();
  }
}
