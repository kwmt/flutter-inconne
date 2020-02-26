import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:http/http.dart' as http;
import 'package:instantonnection/application/AppConfig.dart';
import 'package:instantonnection/domain/model/PaidPlan.dart';
import 'package:instantonnection/domain/model/PurchaseItem.dart'
    as MyPurchaseItem;
import 'package:instantonnection/domain/model/Receipt.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/model/exception/PurchaseException.dart';
import 'package:instantonnection/domain/model/util/EnumUtil.dart';
import 'package:instantonnection/domain/repository/PurchaseRepository.dart';
import 'package:instantonnection/infrastructure/entity/AndroidReceiptEntity.dart';
import 'package:instantonnection/infrastructure/entity/PurchaseItemEntity.dart';
import 'package:instantonnection/infrastructure/entity/ReceiptEntity.dart';
import 'package:instantonnection/infrastructure/entity/ResultLatestReceiptEntity.dart';
import 'package:instantonnection/infrastructure/translator/PurchaseTranslator.dart';

/// PlayStore,AppStore
class PlayAppStoreDatasource implements PurchaseRepository {
  final AppConfig appConfig;

  PlayAppStoreDatasource(this.appConfig);

  PurchaseTranslator _purchaseTranslator = PurchaseTranslator();
  PurchasedTranslator _purchasedTranslator = PurchasedTranslator();

  @override
  Future<String> init() {
    return FlutterInappPurchase.initConnection;
  }

  // 解約やキャンセルしているか確認
  @override
  Future<LatestReceipt> validateReceipt(User user) {
    if (Platform.isAndroid) {
      var url = "${appConfig.baseSubscriptionApiUrl}/android/verify";

      return _requestAndroidSubscription(Os.Android, url, user.paidPlan);
    } else if (Platform.isIOS) {
      var url = "${appConfig.baseSubscriptionApiUrl}/ios/";
      return http.post(url, body: {
        "receipt": user.paidPlan.transactionReceiptForIos
      }).then((response) {
        final parsed = jsonDecode(response.body);
        ResultLatestReceiptEntity result =
            ResultLatestReceiptEntity.fromJson(parsed);
        return LatestReceiptTranslator().toModel(result)..os = Os.iOS;
      });
    }

    return null;
  }

  @override
  Future<LatestReceipt> cancelSubscription(PaidPlan paidPlan) {
    if (Platform.isIOS) {
      return Future.value(null);
    }
    var url = "${appConfig.baseSubscriptionApiUrl}/android/cancel";
    return _requestAndroidSubscription(Os.Android, url, paidPlan);
  }

  Future<LatestReceipt> _requestAndroidSubscription(
      Os os, String url, PaidPlan paidPlan) {
    if (paidPlan == null) {
      return null;
    }
    AndroidReceiptEntity receiptEntity = paidPlan.receiptForAndroid;
    if (receiptEntity == null) {
      return null;
    }

    var body = {
      "package_name": receiptEntity.packageName,
      "subscription_id": receiptEntity.productId,
      "purchase_token": receiptEntity.purchaseToken
    };

    return http.post(url, body: body).then((response) {
      final parsed = jsonDecode(response.body);
      ResultLatestReceiptEntity result =
          ResultLatestReceiptEntity.fromJson(parsed);
      return LatestReceiptTranslator().toModel(result)..os = os;
    });
  }

  @override
  Future<List<MyPurchaseItem.PurchaseItem>> fetchProducts() {
    final List<String> _productList = Platform.isAndroid
        ? [
//            'android.test.purchased',
            this.appConfig.productAdPlan
          ]
        : [this.appConfig.productAdPlan];

    return FlutterInappPurchase.getProducts(_productList).then((items) {
      // PlayStoreやAppStoreに登録しているプラン
      return items
          .map((item) =>
              _purchaseTranslator.toModel(_translateToPurchaseItemEntity(item)))
          .toList();
    });
  }

  @override
  Future<List<MyPurchaseItem.PurchaseItem>> fetchSubscriptions() {
    final List<String> _subscriptionLists = Platform.isAndroid
        ? [
//            'android.test.purchased',
//            'android.test.canceled',
//            'com.instantonnection.app.develop.subscription1'
            this.appConfig.litePlan,
            this.appConfig.proPlan,
            this.appConfig.unlimitedPlan
          ]
        : [
            this.appConfig.litePlan,
            this.appConfig.proPlan,
            this.appConfig.unlimitedPlan
          ];

    return FlutterInappPurchase.getSubscriptions(_subscriptionLists)
        .then((iapItemList) {
      // PlayStoreやAppStoreに登録しているプラン
      List<MyPurchaseItem.PurchaseItem> plans = iapItemList
          .map((item) =>
              _purchaseTranslator.toModel(_translateToPurchaseItemEntity(item)))
          .toList();

//      plans.insert(
//          0,
//          MyPurchaseItem.PurchaseItem.only(
//              productId: this.appConfig.freePlan,
//              localizedPrice: "Free",
//              title: "Free",
//              description: "Free"));
//
      return plans;
    });
  }

  @override
  Future<List<MyPurchaseItem.PurchasedItem>> fetchPurchaseHistory() =>
      FlutterInappPurchase.getPurchaseHistory().then((items) => items
          .map((item) => _purchasedTranslator
              .toModel(_translateToPurchasedItemEntity(item)))
          .toList());

  @override
  Future<MyPurchaseItem.PurchasedItem> buyProduct(String productId) =>
      FlutterInappPurchase.buyProduct(productId)
          .then((item) => _purchasedTranslator
              .toModel(_translateToPurchasedItemEntity(item)))
          .catchError((e) => throw PurchaseException());

  @override
  Future<MyPurchaseItem.PurchasedItem> buySubscription(String productId) =>
      FlutterInappPurchase.buySubscription(productId)
          .then((item) => _purchasedTranslator
              .toModel(_translateToPurchasedItemEntity(item)))
          .catchError((error) {
        // エラーコード統一してほしい・・・
        if (Platform.isAndroid) {
          if (error.code == "InappPurchasePlugin" && error.details is String) {
            // https://developer.android.com/reference/com/android/billingclient/api/BillingClient.BillingResponse#USER_CANCELED
            String details = error.details as String;
            String USER_CANCELED = "1";
            if (details.endsWith(USER_CANCELED)) {
              return;
            }
          }
        } else if (Platform.isIOS) {
          // https://github.com/dooboolab/flutter_inapp_purchase/blob/a249e5fe7563a958c19484db7988362cad3bcb1e/ios/Classes/FlutterInappPurchasePlugin.m#L431
          if (error.code == "E_USER_CANCELLED") {
            return;
          }
        }
        throw error;
      });

  PurchaseItemEntity _translateToPurchaseItemEntity(IAPItem item) {
    return PurchaseItemEntity(
        item.productId,
        item.price,
        item.currency,
        item.localizedPrice,
        item.title,
        item.description,
        item.introductoryPrice,
        item.subscriptionPeriodNumberIOS,
        item.subscriptionPeriodUnitIOS,
        item.subscriptionPeriodAndroid,
        item.introductoryPriceCyclesAndroid,
        item.introductoryPricePeriodAndroid,
        item.freeTrialPeriodAndroid);
  }

  PurchasedItemEntity _translateToPurchasedItemEntity(PurchasedItem item) {
    return PurchasedItemEntity(
      item.transactionDate,
      item.transactionId,
      item.productId,
      Platform.isIOS ? item.transactionReceipt : null,
      Platform.isAndroid ? item.transactionReceipt : null,
      item.purchaseToken,
      item.autoRenewingAndroid,
      item.dataAndroid,
      item.signatureAndroid,
      item.originalTransactionDateIOS,
      item.originalTransactionIdentifierIOS,
    );
  }
}

class ReceiptTranslator {
  Receipt toModel(ReceiptEntity entity) {
    return Receipt(
      productId: entity != null
          ? entity.productId
          : EnumUtil.getValueString(PaidType.Free),
    );
  }
}

class LatestReceiptTranslator {
  ReceiptTranslator _receiptTranslator = ReceiptTranslator();

  LatestReceipt toModel(ResultLatestReceiptEntity entity) {
    return LatestReceipt(
      latestReceipt: _receiptTranslator.toModel(entity.applyReceipt),
      transactionReceipt: entity.latestReceipt,
    );
  }
}
