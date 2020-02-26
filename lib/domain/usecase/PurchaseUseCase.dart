import 'dart:async';

import 'package:instantonnection/domain/model/PaidPlan.dart';
import 'package:instantonnection/domain/model/PurchaseItem.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/model/util/EnumUtil.dart';
import 'package:instantonnection/domain/repository/PurchaseRepository.dart';
import 'package:instantonnection/domain/usecase/UpdateUserProfileUseCase.dart';

abstract class PurchaseUseCase {
  Future<String> init();

  /// 広告非表示プランを購入する
  /// あるユーザー(user)が、ある商品アイテム(purchaseItem)を購入する
  /// @return PaidPlanを更新したUserを返す
  Future<User> buyAdPlan(User user, PurchaseItem purchaseItem);

  Future<User> buyFreePlan(User user, PurchaseItem purchaseItem);

  Future<User> buyLitePlan(User user, PurchaseItem purchaseItem);

  Future<User> buyProPlan(User user, PurchaseItem purchaseItem);

  Future<User> buyUnlimitedPlan(User user, PurchaseItem purchaseItem);

  Future<List<PurchaseItem>> fetchAllProducts();

  Future<List<PurchaseItem>> fetchProducts();

  Future<List<PurchaseItem>> fetchSubscriptions();

  /// 購入履歴一覧を取得する
  Future<List<PurchasedItem>> fetchPurchaseHistory();

  Future<User> updatePaidPlan(
      User user,
      PaidType paidType,
      PaidPlan oldPaidPlan,
      String productId,
      String transactionReceiptForIos,
      String transactionReceiptForAndroid);
}

class PurchaseUseCaseImpl extends PurchaseUseCase {
  final PurchaseRepository purchaseRepository;
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  PurchaseUseCaseImpl(this.purchaseRepository, this.updateUserProfileUseCase);

  @override
  Future<String> init() {
    return purchaseRepository.init();
  }

  @override
  Future<User> buyAdPlan(User user, PurchaseItem purchaseItem) async {
    PurchasedItem purchasedItem =
        await purchaseRepository.buyProduct(purchaseItem.productId);
    user.paidPlan = _translatePurchasePlan(user.paidPlan, purchasedItem);
    bool success = await updateUserProfileUseCase.execute(user);
    if (!success) {
      return null;
    }
    return user;
  }

  @override
  Future<User> buyFreePlan(User user, PurchaseItem purchaseItem) {
    PurchasedItem purchasedItem =
        PurchasedItem(productId: EnumUtil.getValueString(PaidType.Free));
    return _translateAndUpdateProfile(user, purchaseItem, purchasedItem);
  }

  @override
  Future<User> buyLitePlan(User user, PurchaseItem purchaseItem) =>
      _buyPlanImpl(user, purchaseItem);

  @override
  Future<User> buyProPlan(User user, PurchaseItem purchaseItem) =>
      _buyPlanImpl(user, purchaseItem);

  @override
  Future<User> buyUnlimitedPlan(User user, PurchaseItem purchaseItem) =>
      _buyPlanImpl(user, purchaseItem);

  Future<User> _buyPlanImpl(User user, PurchaseItem purchaseItem) async {
    // Androidの場合、すでに購入済みの場合に追加で購入すると、前の購入状態はキャンセルされないので、前の購入をキャンセルしておく
    if (user.paidPlan.paidType != PaidType.Free) {
      await purchaseRepository.cancelSubscription(user.paidPlan);
    }

    PurchasedItem purchasedItem =
        await purchaseRepository.buySubscription(purchaseItem.productId);
    return await _translateAndUpdateProfile(user, purchaseItem, purchasedItem);
  }

  Future<User> _translateAndUpdateProfile(
      User user, PurchaseItem purchaseItem, PurchasedItem purchasedItem) async {
    user.paidPlan = _translatePurchasePlan(user.paidPlan, purchasedItem);
    bool success = await updateUserProfileUseCase.execute(user);
    if (!success) {
      return null;
    }
    return user;
  }

  @override
  Future<User> updatePaidPlan(
      User user,
      PaidType paidType,
      PaidPlan oldPaidPlan,
      String productId,
      String transactionReceiptForIos,
      String transactionReceiptForAndroid) async {
    PurchasedItem purchasedItem = PurchasedItem(
        productId: productId,
        transactionReceiptForIos: transactionReceiptForIos,
        transactionReceiptForAndroid: transactionReceiptForAndroid);
    user.paidPlan = _translatePurchasePlan(oldPaidPlan, purchasedItem);
    bool success = await updateUserProfileUseCase.execute(user);
    if (!success) {
      return null;
    }
    return user;
  }

  @override
  Future<List<PurchaseItem>> fetchAllProducts() =>
      Future.wait([fetchProducts(), fetchSubscriptions()]).then((results) =>
          results.expand((purchaseItemList) => purchaseItemList).toList());

  @override
  Future<List<PurchaseItem>> fetchProducts() =>
      purchaseRepository.fetchProducts();

  @override
  Future<List<PurchaseItem>> fetchSubscriptions() =>
      purchaseRepository.fetchSubscriptions();

  @override
  Future<List<PurchasedItem>> fetchPurchaseHistory() =>
      purchaseRepository.fetchPurchaseHistory();

  /// 各種プランに変更する
  PaidPlan _translatePurchasePlan(
      PaidPlan oldPaidPlan, PurchasedItem purchasedItem) {
    PaidType newPaidType =
        PaidPlan.productIdToPaidType(purchasedItem.productId);
    PaidType type;
    bool isDisplayAd;
    int limitUploadFileCapacity;
    String title;
    switch (newPaidType) {
      case PaidType.Free:
        type = PaidType.Free;
        isDisplayAd = true;
        limitUploadFileCapacity = FreePlanValue.limitUploadFileCapacity;
        title = EnumUtil.getValueString(PaidType.Free);
        break;
      case PaidType.Ad:
        type = PaidType.Ad;
        isDisplayAd = false;
        limitUploadFileCapacity = AdPlanValue.limitUploadFileCapacity;
        title = EnumUtil.getValueString(PaidType.Ad);
        break;
      case PaidType.Lite:
        type = PaidType.Lite;
        isDisplayAd = false;
        limitUploadFileCapacity = LitePlanValue.limitUploadFileCapacity;
        title = EnumUtil.getValueString(PaidType.Lite);
        break;
      case PaidType.Pro:
        type = PaidType.Pro;
        isDisplayAd = false;
        limitUploadFileCapacity = ProPlanValue.limitUploadFileCapacity;
        title = EnumUtil.getValueString(PaidType.Pro);
        break;
      case PaidType.Unlimited:
        type = PaidType.Unlimited;
        isDisplayAd = false;
        limitUploadFileCapacity = UnlimitedPlanValue.limitUploadFileCapacity;
        title = EnumUtil.getValueString(PaidType.Unlimited);
        break;
      default:
        // デフォルトはFree
        type = PaidType.Free;
        isDisplayAd = true;
        limitUploadFileCapacity = FreePlanValue.limitUploadFileCapacity;
        title = EnumUtil.getValueString(PaidType.Free);
        break;
    }

    return PaidPlan(
        paidType: type,
        itemId: purchasedItem.productId,
        title: title,
        isDisplayAd: isDisplayAd,
        displayMessageCount: oldPaidPlan.displayMessageCount,
        createdRoomCount: oldPaidPlan.createdRoomCount,
        uploadedFileCapacity: oldPaidPlan.uploadedFileCapacity,
        limitUploadFileCapacity: limitUploadFileCapacity,
        transactionReceiptForIos: purchasedItem.transactionReceiptForIos,
        transactionReceiptForAndroid:
            purchasedItem.transactionReceiptForAndroid,
        updatedAt: DateTime.now());
  }
}
