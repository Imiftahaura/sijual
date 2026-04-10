import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sijual_app/features/cart/presentation/cart_controller.dart';
import 'package:sijual_app/features/transaction/data/transaction_model.dart';
import '../data/order_model.dart';
import 'history_controller.dart'; 

part 'checkout_controller.g.dart';

@riverpod
class CheckoutController extends _$CheckoutController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> createOrder({
    required OrderRequest request,
    required List<TransactionProductItem> items,
    required bool isBuyNow, // PERBAIKAN: Gunakan parameter flag ini sebagai ganti widget.buyNowData
    required Function(TransactionItem) onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncLoading();
    try {
      final dummyTransaction = TransactionItem(
        id: DateTime.now().millisecondsSinceEpoch,
        invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch}',
        status: 'pending', 
        totalAmount: request.totalAmount,
        createdAt: DateTime.now().toIso8601String(),
        items: items,
        virtualAccount: '8801234567890123',
      );

      // Simpan ke history transaksi
      ref.read(historyControllerProvider.notifier).addTransaction(dummyTransaction);
      
      // SINKRONISASI: Jika bukan 'Beli Sekarang', bersihkan item yang dipilih dari keranjang
      if (!isBuyNow) {
         await ref.read(cartControllerProvider.notifier).clearSelectedItemsAfterCheckout();
      }

      state = const AsyncData(null);
      onSuccess(dummyTransaction);
    } catch (e, st) {
      state = AsyncError(e, st);
      onError(e.toString());
    }
  }
}