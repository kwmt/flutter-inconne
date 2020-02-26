import 'package:instantonnection/domain/model/PaidPlan.dart';
import 'package:instantonnection/domain/model/util/EnumUtil.dart';
import 'package:instantonnection/infrastructure/datasource/util/DateTime.dart';

class PaidPlanEntity {
  static final int freePlanDisplayMessageCount = 100;
  static final bool displayAd = true;

  /// GooglePlay, iTunesのアイテムIDを想定
  String itemId;
  String title;

  /// チャットルームに表示するメッセージ件数
  int displayMessageCount;

  /// アップロードしたファイル容量(単位：バイト)
  int uploadedFileCapacity;

  /// 作成したRoom数
  int createdRoomCount;

  int limitUploadFileCapacity;

  /// 広告を表示するか
  bool isDisplayAd;

  String transactionReceiptForIos;
  String transactionReceiptForAndroid;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  PaidPlanEntity(
      {String itemId,
      String title,
      int displayMessageCount,
      int uploadedFileCapacity,
      int createdRoomCount,
      int limitCreateRoomCount,
      int limitUploadFileCapacity,
      bool isDisplayAd,
      String description,
      String transactionReceiptForIos,
      String transactionReceiptForAndroid,
      DateTime createdAt,
      DateTime updatedAt}) {
    this.itemId = itemId ?? EnumUtil.getValueString(PaidType.Free);
    this.title = title ?? EnumUtil.getValueString(PaidType.Free);
    this.displayMessageCount = displayMessageCount ?? 100;
    this.uploadedFileCapacity = uploadedFileCapacity;
    this.createdRoomCount = createdRoomCount ?? 0;
    this.limitUploadFileCapacity =
        limitUploadFileCapacity ?? 209715; // 209715 = 0.20GB
    this.isDisplayAd = isDisplayAd ?? true;
    this.transactionReceiptForIos = transactionReceiptForIos;
    this.transactionReceiptForAndroid = transactionReceiptForAndroid;
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  PaidPlanEntity.fromJSON(Map json) {
    this.itemId = json['item_id'];
    this.title = json['title'];
    this.displayMessageCount =
        json['display_message_count'] ?? freePlanDisplayMessageCount;
    this.uploadedFileCapacity = json['uploaded_file_capacity'] ?? 0;
    this.createdRoomCount = json['created_room_count'] ?? 0;
    this.limitUploadFileCapacity = json['limit_upload_file_capacity'];
    this.isDisplayAd = json['is_display_ad'] ?? displayAd;
    this.transactionReceiptForIos = json['transaction_receipt_for_ios'];
    this.transactionReceiptForAndroid = json['transaction_receipt_for_android'];
    this.createdAt = DateTimeUtil.parseTime(json['created_at']);
    this.updatedAt = DateTimeUtil.parseTime(json['updated_at']);
  }

  toObject() {
    return <String, dynamic>{
      'item_id': itemId,
      'title': title,
      'display_message_count': displayMessageCount,
      'uploaded_file_capacity': uploadedFileCapacity,
      'created_room_count': createdRoomCount,
      'limit_upload_file_capacity': limitUploadFileCapacity,
      'is_display_ad': isDisplayAd,
      'transaction_receipt_for_ios': transactionReceiptForIos,
      'transaction_receipt_for_android': transactionReceiptForAndroid,
      'created_at': createdAt,
      'updated_at': DateTime.now(),
    };
  }
}
