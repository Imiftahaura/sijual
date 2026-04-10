import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionItem {
  final int id;
  @JsonKey(name: 'invoice_number')
  final String invoiceNumber;
  
  final String status; 
  
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  
  @JsonKey(name: 'created_at')
  final String createdAt;
  
  final List<TransactionProductItem>? items;

  @JsonKey(name: 'payment_url')
  final String? paymentUrl;
  
  @JsonKey(name: 'virtual_account')
  final String? virtualAccount;

  @JsonKey(name: 'tracking_number')
  final String? trackingNumber;

  TransactionItem({
    required this.id,
    required this.invoiceNumber,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.items,
    this.paymentUrl,
    this.virtualAccount,
    this.trackingNumber,
  });

  TransactionItem copyWith({
    String? status,
    String? trackingNumber,
  }) {
    return TransactionItem(
      id: id,
      invoiceNumber: invoiceNumber,
      status: status ?? this.status,
      totalAmount: totalAmount,
      createdAt: createdAt,
      items: items,
      paymentUrl: paymentUrl,
      virtualAccount: virtualAccount,
      trackingNumber: trackingNumber ?? this.trackingNumber,
    );
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) => _$TransactionItemFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionItemToJson(this);
}

@JsonSerializable()
class TransactionProductItem {
  // --- PERBAIKAN: Tambahkan ini agar bisa navigasi ke detail produk ---
 @JsonKey(name: 'id_product')
  final String id; 

  @JsonKey(name: 'product_name')
  final String productName;
  @JsonKey(name: 'product_image')
  final String? productImage;
  final int quantity;
  final double price;

  TransactionProductItem({
    required this.id, // Tambahkan di sini
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
  });

  factory TransactionProductItem.fromJson(Map<String, dynamic> json) => _$TransactionProductItemFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionProductItemToJson(this);
}

// --- EXTENSION ANDA TETAP UTUH DI BAWAH INI ---

extension TransactionStatusExt on String {
  String get label {
    switch (this.toLowerCase()) {
      case 'pending': return 'Menunggu Pembayaran';
      case 'packed': return 'Sedang Dikemas';
      case 'shipping': return 'Dalam Pengiriman';
      case 'delivered': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      default: return this.toUpperCase();
    }
  }

  Color get color {
    switch (this.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'packed': return Colors.blue;
      case 'shipping': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}

extension TransactionItemExt on TransactionItem {
  String get firstItemName {
    if (items != null && items!.isNotEmpty) {
      return items!.first.productName;
    }
    return "Produk Tidak Diketahui";
  }

  int get itemCount {
    if (items != null) {
      return items!.fold(0, (sum, element) => sum + element.quantity);
    }
    return 0;
  }
}