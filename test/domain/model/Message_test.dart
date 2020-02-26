import 'package:flutter_test/flutter_test.dart';
import 'package:instantonnection/domain/model/Message.dart';
import 'package:instantonnection/domain/model/Room.dart';

class TestData {
  Message message;
  List<LinkText> expected;

  TestData(this.message, this.expected);
}

void main() {
  group('Message test', () {
    List<TestData> messageLinkTextList;

    setUpAll(() async {
      RoomUser roomUser = RoomUser(
          userId: "userId1",
          name: "name1",
          photoUrl: "photoUrl1",
          isNotify: false,
          isMine: false);

      messageLinkTextList = [
        TestData(
            Message("iLinkTextd1", "content", null, roomUser, DateTime.now()),
            List()..add(LinkText("content", url: null))),
        TestData(
            Message(
                "id1",
                "unit testはこちらが参考になるかもhttps://flutter.io/testing/#unit-testing",
                null,
                roomUser,
                DateTime.now()),
            List()
              ..add(LinkText("unit testはこちらが参考になるかも", url: null))
              ..add(LinkText("https://flutter.io/testing/#unit-testing",
                  url: "https://flutter.io/testing/#unit-testing"))),
        TestData(
            Message(
                "id1",
                "あいうhttps://cloud.google.com/nodejs/docs/reference/firestore/0.15.x/Transactionたちう",
                null,
                roomUser,
                DateTime.now()),
            List()
              ..add(LinkText("あいう", url: null))
              ..add(LinkText(
                  "https://cloud.google.com/nodejs/docs/reference/firestore/0.15.x/Transaction",
                  url:
                      "https://cloud.google.com/nodejs/docs/reference/firestore/0.15.x/Transaction"))
              ..add(LinkText("たちう", url: null))),
      ];
    });

    test('linkTextList length', () {
      messageLinkTextList.forEach((testData) {
        expect(testData.message.linkTextList.length, testData.expected.length);
      });
    });
    test('No url', () {
      int number = 0;
      TestData testData = messageLinkTextList[number];
      expect(testData.message.linkTextList[number].text,
          testData.expected[number].text);
      expect(testData.message.linkTextList[number].url,
          testData.expected[number].url);
    });
    test('has 1 url', () {
      int number = 1;
      TestData testData = messageLinkTextList[number];

      int i = 0;
      testData.message.linkTextList.forEach((linkText) {
        expect(linkText.text, testData.expected[i].text);
        expect(linkText.url, testData.expected[i].url);
        i++;
      });
    });
    test('url以外の文字列 + url + url以外の文字列', () {
      int number = 2;
      TestData testData = messageLinkTextList[number];

      int i = 0;
      testData.message.linkTextList.forEach((linkText) {
        expect(linkText.text, testData.expected[i].text);
        expect(linkText.url, testData.expected[i].url);
        i++;
      });
    });
  });
}
