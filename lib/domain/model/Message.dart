import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/domain/model/UploadTask.dart';
import 'package:instantonnection/presentation/common/DateTimeFormatUtils.dart';

class Message {
  String id;

  List<LinkText> get linkTextList {
    if (content == null) {
      return null;
    }

    List<LinkText> results = List();
    // https://stackoverflow.com/a/6041965
    RegExp exp = RegExp(
        r'(http|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?');

    String _content = content;

    do {
      if (_content.length == 0) {
        return results;
      }

      Match match = exp.firstMatch(_content);
      if (match == null) {
        return results..add(LinkText(_content));
      }

      // urlが見つかるまでにテキストがあれば追加する
      String str = _content.substring(0, match.start);
      if (str.length > 0) {
        results.add(LinkText(str));
      }
      String url = match.group(0);
      results.add(LinkText(url, url: url));
      _content = _content.substring(match.end, _content.length);
    } while (_content.length > 0);
    return results;
  }

  String content;
  String downloadImageUrl;
  RoomUser roomUser;
  DateTime createdAt = DateTime.now();
  Stream<UploadTask> uploadImageStream;

  /// このメッセージを読んだかどうか。読んだならtrue
//  bool get isAlreadyRead =>
//      user.lastReadTime != null ? user.lastReadTime.isAfter(createdAt) : false;

  String get createdAtString => DateTimeFormatUtils.format(createdAt);

  Message(this.id, this.content, this.downloadImageUrl, this.roomUser,
      this.createdAt);

  Message.create(this.content, this.roomUser);

  Message.createImage(this.downloadImageUrl, this.roomUser);
}

class LinkText {
  String text;
  String url;

  LinkText(this.text, {this.url});
}
