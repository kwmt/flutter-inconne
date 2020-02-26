class PurchaseItemEntity {
  String productId;
  String price;
  String currency;
  String localizedPrice;
  String title;
  String description;
  String introductoryPrice;

  /// ios only
  String subscriptionPeriodNumberIOS;
  String subscriptionPeriodUnitIOS;

  /// android only
  String subscriptionPeriodAndroid;
  String introductoryPriceCyclesAndroid;
  String introductoryPricePeriodAndroid;
  String freeTrialPeriodAndroid;

  PurchaseItemEntity.only(
      {this.productId, this.localizedPrice, this.title, this.description});

  PurchaseItemEntity(
      this.productId,
      this.price,
      this.currency,
      this.localizedPrice,
      this.title,
      this.description,
      this.introductoryPrice,
      this.subscriptionPeriodNumberIOS,
      this.subscriptionPeriodUnitIOS,
      this.subscriptionPeriodAndroid,
      this.introductoryPriceCyclesAndroid,
      this.introductoryPricePeriodAndroid,
      this.freeTrialPeriodAndroid);
}

class PurchasedItemEntity {
  final DateTime transactionDate;
  final String transactionId;
  final String productId;
  final String transactionReceiptForIos;
  final String transactionReceiptForAndroid;
  final String purchaseToken;

  // Android only
  final bool autoRenewingAndroid;
  final String dataAndroid;
  final String signatureAndroid;

  // iOS only
  final DateTime originalTransactionDateIOS;
  final String originalTransactionIdentifierIOS;

  PurchasedItemEntity(
      this.transactionDate,
      this.transactionId,
      this.productId,
      this.transactionReceiptForIos,
      this.transactionReceiptForAndroid,
      this.purchaseToken,
      this.autoRenewingAndroid,
      this.dataAndroid,
      this.signatureAndroid,
      this.originalTransactionDateIOS,
      this.originalTransactionIdentifierIOS);
}
