import 'package:instantonnection/domain/model/PaidPlan.dart';

class Receipt {
  String productId;
  PaidType get paidType {
    return PaidPlan.productIdToPaidType(productId);
  }

  Receipt({this.productId});
}

class LatestReceipt {
  Os os;
  Receipt latestReceipt;
  String transactionReceipt;

  LatestReceipt({this.os, this.latestReceipt, this.transactionReceipt});
}

enum Os { Android, iOS }
