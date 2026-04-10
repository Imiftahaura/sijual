// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionItem _$TransactionItemFromJson(Map<String, dynamic> json) =>
    TransactionItem(
      id: (json['id'] as num).toInt(),
      invoiceNumber: json['invoice_number'] as String,
      status: json['status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      createdAt: json['created_at'] as String,
      items: (json['items'] as List<dynamic>?)
          ?.map(
              (e) => TransactionProductItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      paymentUrl: json['payment_url'] as String?,
      virtualAccount: json['virtual_account'] as String?,
      trackingNumber: json['tracking_number'] as String?,
    );

Map<String, dynamic> _$TransactionItemToJson(TransactionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoice_number': instance.invoiceNumber,
      'status': instance.status,
      'total_amount': instance.totalAmount,
      'created_at': instance.createdAt,
      'items': instance.items,
      'payment_url': instance.paymentUrl,
      'virtual_account': instance.virtualAccount,
      'tracking_number': instance.trackingNumber,
    };

TransactionProductItem _$TransactionProductItemFromJson(
        Map<String, dynamic> json) =>
    TransactionProductItem(
      id: json['id_product'] as String,
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$TransactionProductItemToJson(
        TransactionProductItem instance) =>
    <String, dynamic>{
      'id_product': instance.id,
      'product_name': instance.productName,
      'product_image': instance.productImage,
      'quantity': instance.quantity,
      'price': instance.price,
    };
