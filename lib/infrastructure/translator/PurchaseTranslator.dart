import 'dart:io';

import 'package:instantonnection/domain/model/PurchaseItem.dart';
import 'package:instantonnection/infrastructure/entity/PurchaseItemEntity.dart';

class PurchaseTranslator {
  PurchaseItemEntity toEntity(PurchaseItem model) {}

  PurchaseItem toModel(PurchaseItemEntity entity) {
    return PurchaseItem(
      productId: entity.productId,
      price: entity.price,
      currency: entity.currency,
      localizedPrice: entity.localizedPrice,
      title: entity.title,
      description: entity.description,
      subscriptionPeriod: Platform.isIOS
          ? entity.subscriptionPeriodUnitIOS
          : entity.subscriptionPeriodAndroid,
    );
  }
}

class PurchasedTranslator {
  PurchasedItemEntity toEntity(PurchasedItem model) {}

  PurchasedItem toModel(PurchasedItemEntity entity) {
    return PurchasedItem(
        transactionDate: entity.transactionDate,
        transactionId: entity.transactionId,
        productId: entity.productId,
        transactionReceiptForIos: entity.transactionReceiptForIos,
        transactionReceiptForAndroid: entity.transactionReceiptForAndroid,
        purchaseToken: entity.purchaseToken);
  }
}
