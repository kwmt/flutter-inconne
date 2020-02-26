import 'package:flutter_test/flutter_test.dart';
import 'package:instantonnection/domain/model/Message.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/infrastructure/entity/MessageEntity.dart';
import 'package:instantonnection/infrastructure/translator/MessageTranslator.dart';

class TestData {
  Message message;
  MessageEntity expected;

  TestData(this.message, this.expected);
}

void main() {
  group('MessageTranslator test', () {
    MessageTranslator target;

    List<TestData> testData;

    setUpAll(() {
      target = MessageTranslator();

      RoomUser roomUser = RoomUser(
          userId: "userId1",
          name: "name1",
          photoUrl: "photoUrl1",
          isNotify: false,
          isMine: false);

      testData = List();
      testData.add(TestData(
          Message('testId', 'コンテンツ', null, roomUser,
              DateTime.parse("2012-02-27T14+00:00")),
          MessageEntity('testId', roomUser.userId, 'コンテンツ', null,
              DateTime.parse("2012-02-27T14+00:00"))));
      testData.add(TestData(
          Message('testId', 'コンテンツ', 'https://kwmt27.net', roomUser,
              DateTime.parse("2012-02-27T14+00:00")),
          MessageEntity('testId', roomUser.userId, 'コンテンツ', null,
              DateTime.parse("2012-02-27T14+00:00"))));
      testData.add(TestData(
          Message('testId', null, 'https://kwmt27.net', roomUser,
              DateTime.parse("2012-02-27T14+00:00")),
          MessageEntity('testId', roomUser.userId, null, 'https://kwmt27.net',
              DateTime.parse("2012-02-27T14+00:00"))));
      testData.add(TestData(
          Message('testId', null, null, roomUser,
              DateTime.parse("2012-02-27T14+00:00")),
          MessageEntity('testId', roomUser.userId, null, null,
              DateTime.parse("2012-02-27T14+00:00"))));
    });

    test('messageはcontentもっているが、 downloadImageUrlがない場合', () {
      TestData data = testData[0];
      MessageEntity actual = target.toEntity(data.message);

      expect(actual.id, data.expected.id);
      expect(actual.content, data.expected.content);
      expect(actual.imageUrl, isNull);
      expect(actual.createdAt, data.expected.createdAt);
    });

    test('messageは、contentもdownloadImageUrlも持っている場合', () {
      TestData data = testData[1];
      MessageEntity actual = target.toEntity(data.message);

      expect(actual.id, data.expected.id);
      expect(actual.content, data.expected.content);
      expect(actual.imageUrl, isNull);
      expect(actual.createdAt, data.expected.createdAt);
    });
    test('messageはdownloadImageUrlは持っているが、 contentがない場合', () {
      TestData data = testData[2];
      MessageEntity actual = target.toEntity(data.message);

      expect(actual.id, data.expected.id);
      expect(actual.content, isNull);
      expect(actual.imageUrl, data.expected.imageUrl);
      expect(actual.createdAt, data.expected.createdAt);
    });
    test('messageはcontentもdownloadImageUrlは持っていない場合', () {
      TestData data = testData[3];

      try {
        target.toEntity(data.message);
        fail('Exception expected');
      } on ArgumentError catch (e) {
        expect(e.message, equals("messsageの内容contentかimagefileを指定してください。"));
      } catch (e) {
        fail('ArgumentError expected');
      }
    });
  });
}
