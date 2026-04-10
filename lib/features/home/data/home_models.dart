// lib/features/home/data/home_models.dart
import 'package:json_annotation/json_annotation.dart';
import '../../product/data/product_model.dart';

part 'home_models.g.dart';

@JsonSerializable()
class Location {
  final int id;
  final String name;

  Location({required this.id, required this.name});

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class BannerModel {
  final int id;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  final String? actionUrl;

  BannerModel({required this.id, required this.imageUrl, this.actionUrl});

  factory BannerModel.fromJson(Map<String, dynamic> json) => _$BannerModelFromJson(json);
  Map<String, dynamic> toJson() => _$BannerModelToJson(this);
}

@JsonSerializable()
class Category {
  final int id;
  final String name;
  @JsonKey(name: 'icon_url',defaultValue: '')
  final String iconUrl;

  Category({required this.id, required this.name, this.iconUrl = '',});

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class HomeData {
  final List<BannerModel> banners;
  final List<Category> categories;
  final List<Product> products;
  // Produk trending nanti kita load terpisah atau bisa disatukan di sini
  // Untuk efisiensi awal, kita satukan basic data home
  
  HomeData(
    {required this.banners, 
  required this.categories,required this.products,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) => _$HomeDataFromJson(json);
  Map<String, dynamic> toJson() => _$HomeDataToJson(this);
}