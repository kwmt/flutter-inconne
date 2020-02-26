class PurchaseItem {
  String productId;
  String price;
  String currency;
  String localizedPrice;
  String title;
  String description;
  String subscriptionPeriod;

  PurchaseItem(
      {this.productId,
      this.price,
      this.currency,
      this.localizedPrice,
      this.title,
      this.description,
      this.subscriptionPeriod});

  PurchaseItem.only(
      {this.productId, this.localizedPrice, this.title, this.description});
}

class PurchasedItem {
  DateTime transactionDate;
  String transactionId;
  String productId;
  String transactionReceiptForIos;
  String transactionReceiptForAndroid;
  String purchaseToken;

  PurchasedItem(
      {this.transactionDate,
      this.transactionId,
      this.productId,
      this.transactionReceiptForIos,
      this.transactionReceiptForAndroid,
      this.purchaseToken});

//  // Android only
//  final bool autoRenewingAndroid;
//  final String dataAndroid;
//  final String signatureAndroid;
//
//  // iOS only
//  final DateTime originalTransactionDateIOS;
//  final String originalTransactionIdentifierIOS;

}
