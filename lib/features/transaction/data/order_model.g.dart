// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
      productId: (json['product_id'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
      'product_id': instance.productId,
      'quantity': instance.quantity,
      'price': instance.price,
      'notes': instance.notes,
    };

OrderRequest _$OrderRequestFromJson(Map<String, dynamic> json) => OrderRequest(
      userId: (json['user_id'] as num).toInt(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      shippingAddress: json['shipping_address'] as String,
      shippingCourier: json['shipping_courier'] as String,
      shippingCost: (json['shipping_cost'] as num).toInt(),
      paymentMethod: json['payment_method'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$OrderRequestToJson(OrderRequest instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'total_amount': instance.totalAmount,
      'shipping_address': instance.shippingAddress,
      'shipping_courier': instance.shippingCourier,
      'shipping_cost': instance.shippingCost,
      'payment_method': instance.paymentMethod,
      'items': instance.items,
      'notes': instance.notes,
    };

OrderResponse _$OrderResponseFromJson(Map<String, dynamic> json) =>
    OrderResponse(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      invoiceNumber: json['invoice_number'] as String? ?? 'INV-DUMMY',
      status: json['status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentUrl: json['payment_url'] as String?,
      virtualAccount: json['virtual_account'] as String?,
    );

Map<String, dynamic> _$OrderResponseToJson(OrderResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'invoice_number': instance.invoiceNumber,
      'status': instance.status,
      'total_amount': instance.totalAmount,
      'payment_url': instance.paymentUrl,
      'virtual_account': instance.virtualAccount,
    };
