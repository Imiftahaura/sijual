import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class Product {
  // 1. KEMBALIKAN KEY id_product agar data muncul lagi
  @JsonKey(name: 'id_product', fromJson: _parseInt) 
  final int id;

  @JsonKey(defaultValue: 'Tanpa Nama')
  final String name;

  // 2. Gunakan num agar fleksibel untuk harga
  @JsonKey(fromJson: _parseDouble) 
  final num price;
  
  @JsonKey(name: 'image_url', fromJson: _parseImage) 
  final String imageUrl;
  
  final String? description;
  final dynamic category; 

  @JsonKey(name: 'quantity', fromJson: _parseInt)
  final int stock;

  @JsonKey(includeFromJson: false)
  final bool isPreorder;
  
  @JsonKey(includeFromJson: false)
  final int poDuration;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.description,
    this.category,
    this.stock = 0,
    this.isPreorder = false,
    this.poDuration = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    if (json['image_url'] == null && json['image'] != null) {
      json['image_url'] = json['image'];
    }
    return _$ProductFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  // --- PERBAIKAN LOGIKA HARGA (Agar 1000 tidak jadi 100.000) ---
  
  static num _parseDouble(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val;
    if (val is String) {
      // PERBAIKAN: Gunakan double.tryParse agar desimal "1000.00" tidak jadi "100000"
      // Kita hanya hapus simbol mata uang, tapi titik desimal (.) tetap dijaga
      final clean = val.replaceAll(RegExp(r'[^0-9.]'), ''); 
      return double.tryParse(clean) ?? 0;
    }
    return 0;
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) {
      final clean = val.replaceAll(RegExp(r'[^0-9]'), ''); 
      return int.tryParse(clean) ?? 0;
    }
    return 0;
  }

  static String _parseImage(dynamic val) {
    if (val == null) return "";
    if (val is List && val.isNotEmpty) {
      return val.first.toString();
    }
    return val.toString();
  }
}