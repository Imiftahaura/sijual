// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import '../data/transaction_model.dart';

// part 'history_controller.g.dart';

// // WAJIB: keepAlive true agar data tidak di-reset saat pindah screen
// @Riverpod(keepAlive: true)
// class HistoryController extends _$HistoryController {
//   @override
//   List<TransactionItem> build() {
//     // Balikkan list kosong sebagai state awal
//     return [];
//   }

//   void addTransaction(TransactionItem transaction) {
//     // Tambahkan transaksi baru di posisi paling atas
//     state = [transaction, ...state];
//     print("✅ BERHASIL DISIMPAN: Sekarang ada ${state.length} transaksi di memori");
//   }

//   void updateStatus(int id, String newStatus) {
//     state = [
//       for (final tx in state)
//         if (tx.id == id) tx.copyWith(status: newStatus) else tx
//     ];
//     print("✅ STATUS UPDATED: ID $id sekarang $newStatus");
//   }
  
// }

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/transaction_model.dart';
import '../data/transaction_repository.dart';

part 'history_controller.g.dart';

@Riverpod(keepAlive: true)
class HistoryController extends _$HistoryController {
  @override
  List<TransactionItem> build() {
    return [];
  }

  // Tambahkan transaksi baru ke memori
  void addTransaction(TransactionItem transaction) {
    state = [transaction, ...state];
  }

  // Update status di memori lokal secara instan
  void _updateLocalStatus(int id, String newStatus) {
    state = [
      for (final tx in state)
        if (tx.id == id) tx.copyWith(status: newStatus) else tx
    ];
  }
    void updateStatus(int id, String newStatus) {
    state = [
      for (final tx in state)
        if (tx.id == id) tx.copyWith(status: newStatus) else tx
    ];
    print("✅ STATUS UPDATED: ID $id sekarang $newStatus");
  }

  // FUNGSI BATALKAN (Kirim ke Server + Update Lokal)
  Future<void> cancelTransaction(int transactionId) async {
    try {
      // 1. Panggil API ke Server
      await ref.read(transactionRepositoryProvider).updateTransactionStatus(
            transactionId: transactionId,
            status: 'cancelled',
          );

      // 2. Jika sukses di server, update status di memori lokal agar UI langsung berubah
      _updateLocalStatus(transactionId, 'cancelled');
      
      print("✅ PESANAN $transactionId BERHASIL DIBATALKAN");
    } catch (e) {
      print("❌ GAGAL MEMBATALKAN: $e");
      rethrow; // Lempar error agar bisa ditangkap SnackBar di UI
    }
  }

}