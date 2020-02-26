import 'package:instantonnection/infrastructure/entity/ReceiptEntity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ResultLatestReceiptEntity.g.dart';

@JsonSerializable()
class ResultLatestReceiptEntity {
  @JsonKey(name: 'apply_receipt', nullable: true)
  final ReceiptEntity applyReceipt;
  @JsonKey(name: 'detail_receipts', nullable: true)
  final List<ReceiptEntity> detailReceipts;
  @JsonKey(name: 'latest_receipt', nullable: false)
  final String latestReceipt;

  ResultLatestReceiptEntity(
      {this.applyReceipt, this.detailReceipts, this.latestReceipt});

//  factory ResultLatestReceiptEntity.fromJson(Map<String, dynamic> jsonMap) {
//    return ResultLatestReceiptEntity(
//      applyReceipt: jsonMap['apply_receipt'],
//      detailReceipts:  (jsonMap['detail_receipts'] as List).map((receipt) {
//        return ReceiptEntity.fromJson(receipt);
//      }).toList(),
//      latestReceipt: jsonMap['latest_receipt'] as String,
//    );
//  }

  factory ResultLatestReceiptEntity.fromJson(Map<String, dynamic> json) =>
      _$ResultLatestReceiptEntityFromJson(json);
  Map<String, dynamic> toJson() => _$ResultLatestReceiptEntityToJson(this);
}
