// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: Product._parseInt(json['id_product']),
      name: json['name'] as String? ?? 'Tanpa Nama',
      price: Product._parseDouble(json['price']),
      imageUrl: Product._parseImage(json['image_url']),
      description: json['description'] as String?,
      category: json['category'],
      stock: json['quantity'] == null ? 0 : Product._parseInt(json['quantity']),
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id_product': instance.id,
      'name': instance.name,
      'price': instance.price,
      'image_url': instance.imageUrl,
      'description': instance.description,
      'category': instance.category,
      'quantity': instance.stock,
    };
