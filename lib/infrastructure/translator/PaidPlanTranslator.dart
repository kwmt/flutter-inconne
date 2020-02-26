import 'package:instantonnection/domain/model/PaidPlan.dart';
import 'package:instantonnection/infrastructure/entity/PaidPlanEntity.dart';

class PaidPlanTranslator {
  PaidPlanEntity toEntity(PaidPlan paidPlan) {
    return PaidPlanEntity(
        itemId: paidPlan.itemId,
        title: paidPlan.title,
        displayMessageCount: paidPlan.displayMessageCount,
        uploadedFileCapacity: paidPlan.uploadedFileCapacity,
        createdRoomCount: paidPlan.createdRoomCount,
        limitUploadFileCapacity: paidPlan.limitUploadFileCapacity,
        isDisplayAd: paidPlan.isDisplayAd,
        transactionReceiptForIos: paidPlan.transactionReceiptForIos,
        transactionReceiptForAndroid: paidPlan.transactionReceiptForAndroid,
        createdAt: paidPlan.createdAt ?? DateTime.now(),
        updatedAt: paidPlan.updatedAt ?? DateTime.now());
  }

  PaidPlan toModel(PaidPlanEntity paidPlanEntity) {
    return PaidPlan(
        itemId: paidPlanEntity.itemId,
        title: paidPlanEntity.title,
        displayMessageCount: paidPlanEntity.displayMessageCount,
        uploadedFileCapacity: paidPlanEntity.uploadedFileCapacity,
        createdRoomCount: paidPlanEntity.createdRoomCount,
        limitUploadFileCapacity: paidPlanEntity.limitUploadFileCapacity,
        isDisplayAd: paidPlanEntity.isDisplayAd,
        transactionReceiptForIos: paidPlanEntity.transactionReceiptForIos,
        transactionReceiptForAndroid:
            paidPlanEntity.transactionReceiptForAndroid,
        createdAt: paidPlanEntity.createdAt,
        updatedAt: paidPlanEntity.updatedAt);
  }
}
