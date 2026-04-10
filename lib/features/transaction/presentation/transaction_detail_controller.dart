import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'history_controller.dart';
import '../data/transaction_model.dart';

part 'transaction_detail_controller.g.dart';

@riverpod
Future<TransactionItem> transactionDetail(TransactionDetailRef ref, int transactionId) async {
  // 1. Ambil semua list transaksi dari HistoryController
  final history = ref.watch(historyControllerProvider);

  // 2. Cari transaksi yang ID-nya cocok dengan yang di-klik user
  try {
    final detail = history.firstWhere((tx) => tx.id == transactionId);
    return detail;
  } catch (e) {
    // 3. Jika tidak ada di lokal (misal setelah restart), baru coba ambil ke API
    // final repo = ref.watch(transactionRepositoryProvider);
    // return await repo.getTransactionDetail(transactionId);
    
    throw Exception("Transaksi tidak ditemukan di riwayat.");
  }
}