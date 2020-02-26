import 'dart:convert';
import 'dart:io';

import 'package:instantonnection/domain/model/util/EnumUtil.dart';
import 'package:instantonnection/infrastructure/entity/AndroidReceiptEntity.dart';

class FreePlanValue {
  // アップロード可能容量(単位:byte)
  static const int limitUploadFileCapacity = 214748160;
}

class AdPlanValue {
  // アップロード可能容量(単位:byte)
  static int limitUploadFileCapacity = FreePlanValue.limitUploadFileCapacity;
}

class LitePlanValue {
  // アップロード可能容量(単位:byte)
  static int limitUploadFileCapacity = FreePlanValue.limitUploadFileCapacity;
}

class ProPlanValue {
  // アップロード可能容量(単位:byte)
  static int limitUploadFileCapacity = 1073741824;
}

class UnlimitedPlanValue {
  // アップロード可能容量(単位:byte)
  static int limitUploadFileCapacity = ProPlanValue.limitUploadFileCapacity;
}

class PaidPlan {
  PaidType paidType;

  String itemId;
  String title;
  int displayMessageCount;
  int uploadedFileCapacity;
  int createdRoomCount;

  // 単位バイト
  int limitUploadFileCapacity;

  /// 広告を表示するか
  bool isDisplayAd;
  String description;
  String get transactionReceipt {
    if (Platform.isIOS) {
      return transactionReceiptForIos;
    }
    return transactionReceiptForAndroid;
  }

  String transactionReceiptForIos;
  String transactionReceiptForAndroid;
  AndroidReceiptEntity get receiptForAndroid {
    if (transactionReceiptForAndroid?.isEmpty ?? true) {
      return null;
    }
    return AndroidReceiptEntity.fromJson(
        jsonDecode(transactionReceiptForAndroid));
  }

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  /// ファイル(画像)をアップロードできるか？ true:できる
  bool get canUploadFile {
    switch (paidType) {
      case PaidType.Free:
      case PaidType.Ad:
      case PaidType.Lite:
      case PaidType.Pro:
        return uploadedFileCapacity < limitUploadFileCapacity;
      case PaidType.Unlimited:
        return true;
    }
    return false; // dead
  }

  /// Roomにメッセージを表示するのに制限が掛かっているか？
  /// true: 掛かっている
  bool get isMessageDisplayCountLimited {
    switch (paidType) {
      case PaidType.Free:
      case PaidType.Ad:
        return true;
      case PaidType.Lite:
      case PaidType.Pro:
      case PaidType.Unlimited:
        return false;
    }
  }

  PaidPlan(
      {PaidType paidType,
      String itemId,
      String title,
      int displayMessageCount,
      int uploadedFileCapacity,
      int createdRoomCount,
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
    this.uploadedFileCapacity = uploadedFileCapacity ?? 0;
    this.createdRoomCount = createdRoomCount ?? 0;
    this.limitUploadFileCapacity =
        limitUploadFileCapacity ?? FreePlanValue.limitUploadFileCapacity;
    this.isDisplayAd = isDisplayAd ?? true;
    this.description = description ?? EnumUtil.getValueString(PaidType.Free);
    this.transactionReceiptForIos = transactionReceiptForIos;
    this.transactionReceiptForAndroid = transactionReceiptForAndroid;
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();

    this.paidType = _getPaidType(paidType, this.itemId);
  }

  PaidType _getPaidType(PaidType paidType, String itemId) {
    if (paidType != null) {
      return paidType;
    }
    return productIdToPaidType(itemId);
  }

  static PaidType productIdToPaidType(String productId) {
    if (productId == EnumUtil.getValueString(PaidType.Free)) {
      return PaidType.Free;
    }
    var splitPlan = productId.split('.');
    return PaidType.values.firstWhere((paidType) {
      var splitType = paidType.toString().split('.');
      return splitType.last.toLowerCase() == splitPlan.last.toLowerCase();
    }, orElse: () => PaidType.Free);
  }
}

enum PaidType { Free, Ad, Lite, Pro, Unlimited }
