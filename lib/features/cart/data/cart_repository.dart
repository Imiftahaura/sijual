import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/errors/api_exceptions.dart';
import 'cart_model.dart';

part 'cart_repository.g.dart';

@riverpod
CartRepository cartRepository(CartRepositoryRef ref) {
  return CartRepository(ref.watch(dioProvider));
}

class CartRepository {
  final Dio _dio;

  CartRepository(this._dio);

  // 1. GET CART (VERSI DEBUGGING)
  Future<Cart> getCart() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final userId = sp.getInt('user_id');

      // Cek apakah User ID terbaca?
      if (userId == null) {
        print("❌ [CartRepo] User ID Kosong! Dianggap belum login.");
        return Cart(cartId: 0, items: [], totalItems: 0, totalPrice: 0);
      }

      print("🔍 [CartRepo] Mengambil keranjang untuk User ID: $userId");
      
      // Panggil API
      final response = await _dio.get('/cart/$userId');
      
      // LIHAT DATA ASLI DARI SERVER DI CONSOLE
      print("✅ [CartRepo] Response Server: ${response.data}"); 

      final data = response.data['data'];
      
      // Cek Validitas Data
      if (data == null) {
        print("⚠️ [CartRepo] Data Keranjang NULL dari server");
        return Cart(cartId: 0, items: [], totalItems: 0, totalPrice: 0);
      }

      // Coba Parsing ke Model
      try {
        return Cart.fromJson(data);
      } catch (parseError) {
        print("🔥 [CartRepo] Gagal Parsing JSON: $parseError");
        rethrow; // Lempar error biar muncul di layar HP
      }

    } catch (e) {
      print("🔥 [CartRepo] Error Fetching Cart: $e");
      
      // KHUSUS 404 (Belum punya keranjang) -> Aman return kosong
      if (e is DioException && e.response?.statusCode == 404) {
         print("ℹ️ [CartRepo] User belum punya keranjang (404)");
         return Cart(cartId: 0, items: [], totalItems: 0, totalPrice: 0);
      }
      
      // JANGAN RETURN KOSONG UNTUK ERROR LAIN!
      // Lempar errornya supaya layar HP menampilkan pesan merah, bukan keranjang kosong palsu.
      throw NetworkExceptions.getErrorMessage(e);
    }
  }

  // 2. ADD TO CART
  // 2. ADD TO CART
 // lib/features/cart/data/cart_repository.dart

Future<void> addToCart({required int productId, required int quantity}) async {
  try {
    final sp = await SharedPreferences.getInstance();
    final userId = sp.getInt('user_id');

    if (userId == null) throw "Sesi habis. Silakan login ulang.";

    // Pastikan mengirim data dengan tipe yang diharapkan backend
    final response = await _dio.post('/cart', data: {
      'user_id': userId,
      'id_product': productId.toString(),
      'quantity': quantity,
    });

    print("✅ [CartRepo] Add Success: ${response.data}");
  } catch (e) {
    throw NetworkExceptions.getErrorMessage(e);
  }
}
  // ... (Remove & Update functions sama, pastikan ambil user_id dari SharedPrefs) ...
  Future<void> removeCartItem(int itemId) async {
    try {
       final sp = await SharedPreferences.getInstance();
       final userId = sp.getInt('user_id');
       if (userId == null) return;
       await _dio.delete('/cart/$userId/items/$itemId');
    } catch (e) {}
  }

  Future<void> updateCartItemQuantity({required int itemId, required int quantity}) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final userId = sp.getInt('user_id');
      if (userId == null) return;
      await _dio.put('/cart/$userId/items/$itemId', data: {'quantity': quantity});
    } catch (e) {}
  }
}