import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instantonnection/domain/model/AppTheme.dart';
import 'package:instantonnection/domain/model/BlockUser.dart';
import 'package:instantonnection/domain/model/Message.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/model/util/EnumUtil.dart';
import 'package:instantonnection/domain/repository/RoomRepository.dart';
import 'package:instantonnection/domain/repository/UserRepository.dart';
import 'package:instantonnection/infrastructure/entity/BlockUserEntity.dart';
import 'package:instantonnection/infrastructure/entity/MessageEntity.dart';
import 'package:instantonnection/infrastructure/entity/RoomEntity.dart';
import 'package:instantonnection/infrastructure/entity/RoomUserEntity.dart';
import 'package:instantonnection/infrastructure/entity/ThemeEntity.dart';
import 'package:instantonnection/infrastructure/entity/UserEntity.dart';
import 'package:instantonnection/infrastructure/translator/MessageTranslator.dart';
import 'package:instantonnection/infrastructure/translator/RoomTranslator.dart';
import 'package:instantonnection/infrastructure/translator/RoomUserTranslator.dart';
import 'package:instantonnection/infrastructure/translator/ThemeTranslator.dart';
import 'package:instantonnection/infrastructure/translator/UserTranslator.dart';
import 'package:instantonnection/presentation/report/ReportScreen.dart';
import 'package:intl/intl.dart';

class _Condition {
  final String field;
  final dynamic value;

  _Condition(this.field, this.value);
}

class FirestoreDatasource implements RoomRepository, UserRepository {
  final Firestore _firestore;

  FirestoreDatasource(this._firestore);

  final UserTranslator _userTranslator = UserTranslator();
  final RoomTranslator _roomTranslator = RoomTranslator();
  final MessageTranslator _messageTranslator = MessageTranslator();
  final RoomUserTranslator _roomUserTranslator = RoomUserTranslator();
  final ThemeTranslator _themeTranslator = ThemeTranslator();

  /// --------------------------------------------------------------------------
  /// [RoomRepository]
  /// --------------------------------------------------------------------------

  _Condition _createRoomListCondition(UserEntity userEntity) {
    String field = "members.${userEntity.uid}";
    dynamic value = true;
    return _Condition(field, value);
  }

  @override
  Future<List<Room>> fetchRoomList(User user) async {
    final UserEntity userEntity = _userTranslator.toEntity(user);
    final _Condition condition = _createRoomListCondition(userEntity);

    QuerySnapshot querySnapshot = await _firestore
        .collection('rooms')
        .where(condition.field,
            isEqualTo: condition
                .value) // js sdkで array_containsとかできるようになったのでAndroidも期待する
//        .orderBy("created_at", descending: true)
        .getDocuments();
    return _fetchRoomListWithMembers(querySnapshot.documents, userEntity);
  }

  @override
  Future<Room> fetchRoom(String roomId, User user) async {
    final UserEntity userEntity = _userTranslator.toEntity(user);

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('rooms').document(roomId).get();
    List<Room> results = await _fetchRoomListWithMembers(
        List()..add(documentSnapshot), userEntity);
    return results.first;
  }

  @override
  Future<List<User>> fetchMemberListOfRoom(Room room) async {
    // TODO: 必要ならfetchMemberListOfRoomの実装
//    return _fetchMemberListOfRoomImpl(_roomTranslator.toEntity(room))
//        .then(_userTranslator.toModelList);
    return null;
  }

  Future<List<RoomUserEntity>> _fetchMemberListOfRoomImpl(
      RoomEntity room, UserEntity userEntity) async {
    QuerySnapshot snapshot = await _firestore
        .collection('rooms')
        .document(room.id)
        .collection('members')
        .getDocuments();

    return snapshot.documents
        .map((document) =>
            RoomUserEntity.fromJSON(document.documentID, document.data))
        .map((roomUserEntity) =>
            roomUserEntity..isMine = roomUserEntity.userId == userEntity.uid)
        .toList();
  }

  @override
  StreamSubscription watchRoomList(User user, void onChange(List<Room> room)) {
    UserEntity userEntity = _userTranslator.toEntity(user);
    _Condition condition = _createRoomListCondition(userEntity);
    StreamSubscription stream = _firestore
        .collection('rooms')
        .where(condition.field,
            isEqualTo: condition
                .value) // js sdkで array_containsとかできるようになったのでAndroidも期待する
        .snapshots()
        .listen((querySnapshot) async {
      List<Room> roomList =
          await _fetchRoomListWithMembers(querySnapshot.documents, userEntity);
      onChange(roomList);
    });

    return stream;
  }

  /// Roomメンバーを取得し、Roomリストを返す
  Future<List<Room>> _fetchRoomListWithMembers(
      List<DocumentSnapshot> documentSnapshots, UserEntity userEntity) async {
    List<RoomEntity> roomList = documentSnapshots
        .map((document) =>
            RoomEntity.fromJSON(document.data, document.documentID))
//        .where((roomEntity) => roomEntity.members.contains(userEntity.uid))
        .toList();

    // 参加しているRoomのメンバーリストを取得する
    List<Future<List<RoomUserEntity>>> fetchMemberListOfRoomFutureList =
        roomList.map((roomEntity) {
      return _fetchMemberListOfRoomImpl(roomEntity, userEntity);
    }).toList();

    List<List<RoomUserEntity>> membersOfRoomList =
        await Future.wait(fetchMemberListOfRoomFutureList);

    // RoomListの各Roomのmembersにセットする
    int i = 0;
    List<RoomEntity> updatedRoomList = roomList.map((roomEntity) {
      roomEntity.members = membersOfRoomList[i];
      i++;
      return roomEntity;
    }).toList();

    return Future.value(
        _roomTranslator.toModelList(_sortRoomList(updatedRoomList)));
  }

  List<RoomEntity> _sortRoomList(List<RoomEntity> roomList) {
    // FIXME: Queryでソートできるようになったらそっちでやりたい
    roomList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return roomList;
  }

  Query _createFetchMessagesQuery(Room room, User user) {
    Query query = _firestore
        .collection('rooms')
        .document(room.id)
        .collection("messages")
        .orderBy("created_at", descending: true);

    // FIXME: domain層で判断出来ないものか？
    if (user.paidPlan.isMessageDisplayCountLimited) {
      query.limit(user.paidPlan.displayMessageCount);
    }
    return query;
  }

  @override
  StreamSubscription watchRoom(
      Room room, User user, void onChange(List<Message> message)) {
    StreamSubscription stream =
        _createFetchMessagesQuery(room, user).snapshots().listen((querySnapshot) {
      List<Message> messages = querySnapshot.documents.map((document) {
        MessageEntity messageEntity =
            MessageEntity.fromJSON(document.data, document.documentID);
        RoomUser user = room.members.firstWhere(
            (member) => member.userId == messageEntity.fromUserId,
            orElse: () => RoomUser());
        messageEntity.roomUser = _roomUserTranslator.toEntity(room, user);
        return _messageTranslator.toModel(messageEntity);
      }).toList();
      onChange(messages);
    });

    return stream;
  }

  @override
  Future<bool> createNewRoom(Room room, User user) async {
    // 一旦Roomを作ってからメンバーを追加する必要があるので、awaitしている
    await this
        ._firestore
        .collection("rooms")
        .document(room.id)
        .setData(_roomTranslator.toEntity(room).toObject());

    return addMemberOfRoom(room, user);
  }

  @override
  Future<bool> updateRoom(Room room) async {
    RoomEntity roomEntity = _roomTranslator.toEntity(room);
    DocumentReference roomRef =
        this._firestore.collection("rooms").document(roomEntity.id);

    final TransactionHandler transactionHandler = (Transaction tx) async {
      DocumentSnapshot roomSnapshot = await tx.get(roomRef);
      if (roomSnapshot.exists) {
        await tx.update(roomRef, roomEntity.toObject());
      }
    };

    await this._firestore.runTransaction(transactionHandler);
    return Future.value(true);
  }

  @override
  Future<bool> updateLatestMessage(Room room, Message message) async {
    DocumentReference roomRef =
        this._firestore.collection("rooms").document(room.id);

    final TransactionHandler transactionHandler = (Transaction tx) async {
      DocumentSnapshot roomSnapshot = await tx.get(roomRef);
      if (roomSnapshot.exists) {
        RoomEntity roomEntity =
            RoomEntity.fromJSON(roomSnapshot.data, roomSnapshot.documentID)
              ..lastMessage = _messageTranslator.toEntity(message);

        await tx.update(roomRef, roomEntity.toObject());
      }
    };

    await this._firestore.runTransaction(transactionHandler);
    return Future.value(true);
  }

  @override
  Future<bool> addMemberToRoom(String roomId, User user) async {
    DocumentReference roomRef =
        this._firestore.collection("rooms").document(roomId);

    final TransactionHandler transactionHandler = (Transaction tx) async {
      DocumentSnapshot roomSnapshot = await tx.get(roomRef);
      if (roomSnapshot.exists) {
        await tx.update(roomRef, <String, dynamic>{
          'members.${user.uid}': true,
          'updated_at': DateTime.now()
        });
      }
    };

    await this._firestore.runTransaction(transactionHandler);
    return Future.value(true);
  }

  @override
  Future<bool> deleteMemberRoom(Room room, User user) async {
    RoomEntity roomEntity = _roomTranslator.toEntity(room);

    DocumentReference roomRef =
        this._firestore.collection("rooms").document(roomEntity.id);

    final TransactionHandler transactionHandler = (Transaction tx) async {
      DocumentSnapshot roomSnapshot = await tx.get(roomRef);
      if (roomSnapshot.exists) {
        await tx.update(roomRef, <String, dynamic>{
          'members': roomEntity.toMembersObject(),
          'updated_at': DateTime.now()
        });
      }
    };

    await this._firestore.runTransaction(transactionHandler);
    return Future.value(true);
  }

  @override
  Future<bool> addMemberOfRoom(Room room, User user) async {
    UserEntity userEntity = _userTranslator.toEntity(user);

    RoomUser roomUser = user.toRoomUser(isNotify: true, isMine: true);
    RoomUserEntity roomUserEntity =
        _roomUserTranslator.roomUserToEntity(roomUser);

    try {
      await this
          ._firestore
          .collection("rooms")
          .document(room.id)
          .collection("members")
          .document(userEntity.uid)
          .setData(roomUserEntity.toObject());
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> deleteMemberFromRoom(Room room, User user) async {
    UserEntity userEntity = _userTranslator.toEntity(user);

    try {
      await this
          ._firestore
          .collection("rooms")
          .document(room.id)
          .collection("members")
          .document(userEntity.uid)
          .delete();

      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> createNewMessage(Room room, Message message) async {
    Future<void> createMessageFuture = this
        ._firestore
        .collection("rooms")
        .document(room.id)
        .collection("messages")
        .document()
        .setData(_messageTranslator.toEntity(message).toObject());

    await Future.wait(
        [createMessageFuture, updateLatestMessage(room, message)]);

    return Future.value(true);
  }

  @override
  Future<RoomUser> updateRoomUser(Room room) async {
    final RoomEntity roomEntity = _roomTranslator.toEntity(room);
    final RoomUserEntity roomUserEntity =
        _roomUserTranslator.toEntity(room, room.myRoomUser);
    DocumentReference memberRef = this
        ._firestore
        .collection("rooms")
        .document(roomEntity.id)
        .collection("members")
        .document(roomUserEntity.userId);

    final TransactionHandler transactionHandler = (Transaction tx) async {
      DocumentSnapshot memberSnapshot = await tx.get(memberRef);

      if (memberSnapshot.exists) {
        await tx.update(memberRef, roomUserEntity.toObject());
      }
    };

    await this._firestore.runTransaction(transactionHandler);

    // 更新後、参照する
    DocumentSnapshot memberDocumentSnapshot = await memberRef.get();
    RoomUserEntity updateRoomUserEntity = RoomUserEntity.fromJSON(
        memberDocumentSnapshot.documentID, memberDocumentSnapshot.data);
    return _roomUserTranslator.toModel(updateRoomUserEntity)..isMine = true;
  }

  @override
  Future<void> reportRoom(User user, Room room, ReportType type) {
    return _reportImpl(user, room, type);
  }

  @override
  Future<void> reportMessage(
      User user, Room room, Message message, ReportType type) {
    return _reportImpl(user, room, type, message: message);
  }

  Future<void> _reportImpl(User user, Room room, ReportType type,
      {Message message}) {
    UserEntity userEntity = _userTranslator.toEntity(user);
    RoomEntity roomEntity = _roomTranslator.toEntity(room);
    MessageEntity messageEntity;
    if (message != null) {
      messageEntity = _messageTranslator.toEntity(message);
    }

    DateTime now = DateTime.now();
    int reportId = now.microsecondsSinceEpoch;

    Map<String, dynamic> reportData = <String, dynamic>{
      "created_at": now,
      'report_type': EnumUtil.getValueString(type),
      "user": userEntity.toObject(),
      "room": roomEntity.toObject(),
      "message": messageEntity?.toObject(),
    };

    return this
        ._firestore
        .collection("reports")
        .document("$reportId")
        .setData(reportData);
  }

  /// --------------------------------------------------------------------------
  /// [UserRepository]
  /// --------------------------------------------------------------------------

  /// 新規ユーザーを作成する
  @override
  Future<User> createNewUser(User user) async {
    UserEntity userEntity = _userTranslator.toEntity(user);

    await this
        ._firestore
        .collection("users")
        .document(user.uid)
        .setData(userEntity.toObject());

    return Future.value(_userTranslator.toModel(userEntity));
  }

  /// 登録ずみかどうか
  /// 登録済みならUser情報を返す。未登録ならnullを返す。
  @override
  Future<User> fetchUser(User user) async {
    DocumentSnapshot snapshot = await this
        ._firestore
        .collection("users")
//        .where("uid", isEqualTo: userEntity.uid).getDocuments();
        .document(user.uid)
        .get();

//    if(snapshot.documents.length == 0) {
//      return Future.value(null);
//
//    }
    if (snapshot.data == null) {
      return Future.value(null);
    }
    return Future.value(
        _userTranslator.toModel(UserEntity.fromJSON(snapshot.data)));
  }

  @override
  Future<String> createNotificationToken(User user, String token) async {
    await this
        ._firestore
        .collection("users")
        .document(user.uid)
        .collection("notificationTokens")
        .document(token)
        .setData({'updated_at': DateTime.now()});

    return Future.value(token);
  }

  @override
  Future<List<AppTheme>> fetchThemes() async {
//    List<ThemeEntity> themes = [
//      ThemeEntity("theme0","0xFF009688", "0xFFFF4081", name:'teal' ,order: 1, isDefault: true),
//      ThemeEntity("theme1","0xFFE91E63", "0xFFFF9800", name:'pink' ,order: 2, isDefault: false),
//      ThemeEntity("theme2","0xFFF44336", "0xFFFF9800", name:'red' ,order: 3, isDefault: false),
//      ThemeEntity("theme3","0xFF9C27B0", "0xFFFF9800", name:'purple' ,order: 4, isDefault: false),
//      ThemeEntity("theme4","0xFF03A9F4", "0xFFFF9800", name:'blue' ,order: 5, isDefault: false),
//    ];
//
//    await Future.wait(
//        [
//          this._firestore.collection("themes").document(themes[0].id).setData(themes[0].toObject()),
//          this._firestore.collection("themes").document(themes[1].id).setData(themes[1].toObject()),
//          this._firestore.collection("themes").document(themes[2].id).setData(themes[2].toObject()),
//          this._firestore.collection("themes").document(themes[3].id).setData(themes[3].toObject()),
//          this._firestore.collection("themes").document(themes[4].id).setData(themes[4].toObject()),
//        ]);

    QuerySnapshot snapshot =
        await _firestore.collection('themes').orderBy('order').getDocuments();

    List<DocumentSnapshot> documentSnapshots = snapshot.documents;

    List<AppTheme> themeList = documentSnapshots
        .map((document) => _themeTranslator
            .toModel(ThemeEntity.fromJSON(document.data, document.documentID)))
        .toList();

    return Future.value(themeList);
  }

  @override
  Future<BlockUserList> fetchBlockUsers(User user) async {
    QuerySnapshot snapshot = await _firestore
        .collection("users")
        .document(user.uid)
        .collection("block_users")
        .getDocuments();

    List<DocumentSnapshot> documentSnapshots = snapshot.documents;

    List<RoomUser> blockUsers = documentSnapshots.map((document) {
      BlockUserEntity entity = BlockUserEntity.fromJSON(document.data);
      return RoomUser(
        userId: entity.uid,
        photoUrl: entity.photoUrl,
        name: entity.name,
      );
    }).toList();

    return BlockUserList(blockUsers);
  }

  @override
  Future<void> addBlockUser(User user, RoomUser roomUser) {
    assert(roomUser != null);
    assert(roomUser.userId != null);

    BlockUserEntity blockUserEntity = BlockUserEntity(
        uid: roomUser.userId, name: roomUser.name, photoUrl: roomUser.photoUrl);
    return _firestore
        .collection("users")
        .document(user.uid)
        .collection("block_users")
        .document(roomUser.userId)
        .setData(blockUserEntity.toObject());
  }

  @override
  Future<void> removeBlockUser(User user, RoomUser blockUser) {
    assert(user != null);
    assert(user.uid != null);
    assert(blockUser.userId != null);
    return _firestore
        .collection("users")
        .document(user.uid)
        .collection("block_users")
        .document(blockUser.userId)
        .delete();
  }

  @override
  Future<bool> update(User user) async {
    DocumentReference userRef =
        this._firestore.collection("users").document(user.uid);

    final TransactionHandler transactionHandler = (Transaction tx) async {
      DocumentSnapshot snapshot = await tx.get(userRef);
      if (snapshot.exists) {
        UserEntity userEntity = UserEntity.fromJSON(snapshot.data);
        // iOSで実行中ならAndroidのtransactionReceiptを保持
        // Androidで実行中ならiOSのtransactionReceiptを保持
        if (Platform.isIOS) {
          user.paidPlan.transactionReceiptForAndroid =
              userEntity.paidPlanEntity.transactionReceiptForAndroid;
        } else if (Platform.isAndroid) {
          user.paidPlan.transactionReceiptForIos =
              userEntity.paidPlanEntity.transactionReceiptForIos;
        }

        userEntity = _userTranslator.toEntity(user); //更新
        await tx.update(userRef, userEntity.toObject());
      }
    };

    await this._firestore.runTransaction(transactionHandler);
    return Future.value(true);
  }
}
