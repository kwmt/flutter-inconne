import 'dart:async';

import 'package:instantonnection/domain/model/PaidPlan.dart';
import 'package:instantonnection/domain/model/PurchaseItem.dart';
import 'package:instantonnection/domain/model/Receipt.dart';
import 'package:instantonnection/domain/model/User.dart';

abstract class PurchaseRepository {
  Future<String> init();

  Future<LatestReceipt> validateReceipt(User user);

  Future<List<PurchaseItem>> fetchProducts();

  Future<List<PurchaseItem>> fetchSubscriptions();

  Future<List<PurchasedItem>> fetchPurchaseHistory();

  Future<PurchasedItem> buyProduct(String productId);
  Future<PurchasedItem> buySubscription(String productId);

  Future<LatestReceipt> cancelSubscription(PaidPlan paidPlan);
}
