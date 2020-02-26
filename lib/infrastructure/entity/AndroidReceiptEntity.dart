import 'package:json_annotation/json_annotation.dart';

part 'AndroidReceiptEntity.g.dart';

@JsonSerializable()
class AndroidReceiptEntity {
  @JsonKey(name: 'orderId', nullable: true)
  final String orderId;
  @JsonKey(name: 'packageName', nullable: true)
  final String packageName;
  @JsonKey(name: 'productId', nullable: true)
  final String productId;
  @JsonKey(name: 'purchaseTime', nullable: true)
  final int purchaseTime;
  @JsonKey(name: 'purchaseState', nullable: true)
  final int purchaseState;
  @JsonKey(name: 'purchaseToken', nullable: true)
  final String purchaseToken;
  @JsonKey(name: 'autoRenewing', nullable: true)
  final bool autoRenewing;

  AndroidReceiptEntity(
      {this.orderId,
      this.packageName,
      this.purchaseTime,
      this.purchaseState,
      this.purchaseToken,
      this.autoRenewing,
      this.productId});

  factory AndroidReceiptEntity.fromJson(Map<String, dynamic> json) =>
      _$AndroidReceiptEntityFromJson(json);

  Map<String, dynamic> toJson() => _$AndroidReceiptEntityToJson(this);
}
