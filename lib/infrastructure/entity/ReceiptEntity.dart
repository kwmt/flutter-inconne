import 'package:json_annotation/json_annotation.dart';

part 'ReceiptEntity.g.dart';

@JsonSerializable()
class ReceiptEntity {
  @JsonKey(name: 'product_id', nullable: false)
  final String productId;

  ReceiptEntity({this.productId});

  factory ReceiptEntity.fromJson(Map<String, dynamic> json) =>
      _$ReceiptEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiptEntityToJson(this);
}
