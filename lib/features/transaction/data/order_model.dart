import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

@JsonSerializable()
class OrderItem {
  @JsonKey(name: 'product_id')
  final int productId;
  final int quantity;
  final double price;
  final String? notes;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}

@JsonSerializable()
class OrderRequest {
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  @JsonKey(name: 'shipping_address')
  final String shippingAddress;
  @JsonKey(name: 'shipping_courier')
  final String shippingCourier;
  @JsonKey(name: 'shipping_cost')
  final int shippingCost;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  final List<OrderItem> items;
  final String? notes;

  OrderRequest({
    required this.userId,
    required this.totalAmount,
    required this.shippingAddress,
    required this.shippingCourier,
    required this.shippingCost,
    required this.paymentMethod,
    required this.items,
    this.notes,
  });

  Map<String, dynamic> toJson() => _$OrderRequestToJson(this);
}

@JsonSerializable()
class OrderResponse {
  final int id;
  
  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'invoice_number', defaultValue: 'INV-DUMMY')
  final String invoiceNumber;
  
  final String status;
  
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  
  // FIELD TAMBAHAN UNTUK LINK PEMBAYARAN
  @JsonKey(name: 'payment_url') 
  final String? paymentUrl; 

  // FIELD TAMBAHAN UNTUK VA (PERBAIKAN ERROR KAMU)
  @JsonKey(name: 'virtual_account')
  final String? virtualAccount; 

  OrderResponse({
    required this.id,
    required this.userId,
    required this.invoiceNumber,
    required this.status,
    required this.totalAmount,
    this.paymentUrl,
    this.virtualAccount,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) => _$OrderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderResponseToJson(this);
}