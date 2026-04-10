class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double price; 
  final int quantity;
  final String? image;
  final bool isSelected;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.image,
    this.isSelected = true,
  });

  // --- PARSING MANUAL PINTAR ---
  factory CartItem.fromJson(Map<String, dynamic> json) {
    
    // 1. CARI NAMA (Cek level luar -> Cek level product)
    String name = 'Produk Tanpa Nama';
    if (json['product_name'] != null) {
      name = json['product_name'].toString();
    } else if (json['product'] is Map && json['product']['name'] != null) {
      name = json['product']['name'].toString();
    } else if (json['name'] != null) {
      name = json['name'].toString();
    }

  
    double finalPrice = 0.0;
    if (json['price'] != null) {
      finalPrice = _parseDouble(json['price']);
    } else if (json['product'] is Map && json['product']['price'] != null) {
      finalPrice = _parseDouble(json['product']['price']);
    }

    dynamic rawImage;
    
    // Prioritas 1: Cek di luar (image / image_url)
    if (json['image'] != null) rawImage = json['image'];
    else if (json['image_url'] != null) rawImage = json['image_url'];
    
    // Prioritas 2: Cek di dalam object 'product' (image_url / images)
    else if (json['product'] is Map) {
       if (json['product']['image_url'] != null) {
         rawImage = json['product']['image_url'];
       } else if (json['product']['image'] != null) {
         rawImage = json['product']['image'];
       } else if (json['product']['images'] != null) {
         rawImage = json['product']['images']; // Kadang server kirim 'images' (jamak)
       }
    }

    return CartItem(
      id: _parseInt(json['id']),
      productId: _parseInt(
        json['id_product'] ?? 
        json['product_id'] ?? 
        (json['product'] is Map ? json['product']['id_product'] : 0)
      ),
      productName: name, 
      price: finalPrice,
      quantity: _parseInt(json['quantity']),
      // Gunakan parser canggih ini agar foto pasti muncul
      image: _parseImage(rawImage), 
      isSelected: true,
    );
  }
  
  CartItem copyWith({int? quantity, bool? isSelected}) {
    return CartItem(
      id: id,
      productId: productId,
      productName: productName,
      price: price,
      quantity: quantity ?? this.quantity,
      image: image,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  
  static String? _parseImage(dynamic val) {
    if (val == null) return null;
    if (val is String && val.isNotEmpty) {
      return val;
    }
    if (val is List && val.isNotEmpty) {
      return val.first.toString(); 
    }
    
    return null;
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

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) {
      final clean = val.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(clean) ?? 0.0;
    }
    return 0.0;
  }
}

class Cart {
  final int cartId;
  final List<CartItem> items;
  final int totalItems;
  final double totalPrice;

  Cart({
    required this.cartId,
    required this.items,
    required this.totalItems,
    required this.totalPrice,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    var list = json['items'];
    List<CartItem> itemsList = [];
    
   
    if (list is List) {
      itemsList = list.map<CartItem>((i) => CartItem.fromJson(i)).toList();
    }

    return Cart(
      cartId: CartItem._parseInt(json['id']),
      items: itemsList,
      totalItems: CartItem._parseInt(json['total_items']),
      totalPrice: CartItem._parseDouble(json['total_price']),
    );
  }
  
  Cart recalculate() {
    final selectedItems = items.where((e) => e.isSelected);
    int newTotalItems = 0;
    double newTotalPrice = 0;
    for (var item in selectedItems) {
      newTotalItems += item.quantity;
      newTotalPrice += (item.price * item.quantity);
    }
    return Cart(
      cartId: cartId,
      items: items,
      totalItems: newTotalItems,
      totalPrice: newTotalPrice,
    );
  }
}