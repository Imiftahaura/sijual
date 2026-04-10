import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/errors/api_exceptions.dart';
import 'order_model.dart';
import 'transaction_model.dart';

part 'transaction_repository.g.dart';

@riverpod
TransactionRepository transactionRepository(TransactionRepositoryRef ref) {
  return TransactionRepository(ref.watch(dioProvider));
}

class TransactionRepository {
  final Dio _dio;
  TransactionRepository(this._dio);

  // 1. CREATE ORDER (Sinkronisasi dengan CheckoutController)
  // Kita kembalikan TransactionItem agar UI bisa langsung pakai data lengkap
  Future<TransactionItem> createOrder(OrderRequest request) async {
    try {
      // Mengirim data checkout ke server asli
      final response = await _dio.post('/checkout', data: request.toJson());
      
      final data = response.data;
      if (data['success'] == true) {
        // Balikan dari server dikonversi ke TransactionItem
        // Pastikan backend mengembalikan struktur yang sesuai dengan TransactionItem
        return TransactionItem.fromJson(data['data']);
      } else {
        throw data['message'] ?? "Gagal membuat pesanan";
      }
    } catch (e) {
      // Jika server mati/error, kita lempar error yang cantik
      throw NetworkExceptions.getErrorMessage(e);
    }
  }

  // 2. GET TRANSACTIONS
  Future<List<TransactionItem>> getTransactions({String? status}) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final userId = sp.getInt('user_id');

      final queryParams = {
        'user_id': userId,
        if (status != null) 'status': status, 
      };

      final response = await _dio.get('/orders', queryParameters: queryParams);
      
      // Mengambil List data dari key 'data' sesuai format standar API kamu
      final List rawList = response.data['data'] ?? [];

      return rawList.map<TransactionItem>((json) => TransactionItem.fromJson(json)).toList();
      
    } catch (e) {
      // Jika gagal koneksi, return list kosong agar layar History tidak merah (error)
      print("❌ Error Fetch History: $e");
      return []; 
    }
  }

  // 3. CEK STATUS PEMBAYARAN (Untuk Auto-refresh di layar VA)
  Future<bool> checkPaymentStatus(int orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId');
      
      final data = response.data['data'];
      final String serverStatus = data['status'].toString().toLowerCase(); 
      
      print("🔍 Status Server Order #$orderId: $serverStatus");
      
      // Logika: Jika status sudah bukan pending/waiting, berarti sudah dibayar/batal
      const nonPaidStatus = ['pending', 'waiting_payment', 'unpaid'];
      if (!nonPaidStatus.contains(serverStatus)) {
        return true; 
      }
      return false; 
    } catch (e) {
      return false; 
    }
  }
 Future<void> updateTransactionStatus({required int transactionId, required String status}) async {
  try {
    // Kita coba gunakan PATCH ke /orders/id, ini adalah standar paling umum
    await _dio.patch('/orders/$transactionId', data: {
      'status': status,
    });
    print("✅ Server Sync Success: $status");
  } on DioException catch (e) {
    // Jika 404, berarti backend memang belum buat rute ini
    if (e.response?.statusCode == 404) {
      print("⚠️ Backend 404: Rute update status belum ada di server.");
      // Jangan rethrow agar aplikasi tidak dianggap 'crash'
      return; 
    }
    rethrow;
  }
}
  // 4. DETAIL TRANSAKSI
  Future<TransactionItem> getTransactionDetail(int id) async {
    try {
      final response = await _dio.get('/orders/$id');
      final data = response.data['data'];
      
      return TransactionItem.fromJson(data);
    } catch (e) {
      throw NetworkExceptions.getErrorMessage(e);
    }
  }
}