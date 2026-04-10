import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sijual_app/features/auth/presentation/auth_controller.dart';
import '../data/cart_model.dart';
import '../data/cart_repository.dart';

part 'cart_controller.g.dart';

@riverpod
class CartController extends _$CartController {
  @override
  FutureOr<Cart> build() {
    return ref.read(cartRepositoryProvider).getCart();
  }

  // --- HELPER HITUNG TOTAL ---
  Cart _recalculateTotal(List<CartItem> items) {
    double newTotal = 0; 
    int newCount = 0;
    for (var item in items) {
      if (item.isSelected) {
        newTotal += item.price * item.quantity;
        newCount += item.quantity;
      }
    }
    final oldCartId = state.value?.cartId ?? 0;
    return Cart(
      cartId: oldCartId,
      items: items,
      totalPrice: newTotal,
      totalItems: newCount, 
    );
  }

// lib/features/cart/presentation/cart_controller.dart

Future<dynamic> addToCart(int productId, int quantity) async {
  // Langsung ambil value user
  final user = ref.read(authControllerProvider).value;
  
  if (user == null) {
    return "Silakan login terlebih dahulu";
  }

  try {
    await ref.read(cartRepositoryProvider).addToCart(
      productId: productId, 
      quantity: quantity
    );
    
    // PENTING: Invalidate agar UI Keranjang & Badge langsung update
    ref.invalidateSelf(); 
    return true;
  } catch (e) {
    return e.toString();
  }
}





  void toggleSelection(int itemId) {
    final currentState = state.value;
    if (currentState == null) return;
    final updatedItems = currentState.items.map((item) {
      if (item.id == itemId) return item.copyWith(isSelected: !item.isSelected);
      return item;
    }).toList();
    state = AsyncData(_recalculateTotal(updatedItems));
  }

  void toggleAll(bool value) {
    final currentState = state.value;
    if (currentState == null) return;
    final updatedItems = currentState.items.map((item) => item.copyWith(isSelected: value)).toList();
    state = AsyncData(_recalculateTotal(updatedItems));
  }

  Future<void> refreshCart() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(cartRepositoryProvider).getCart());
  }

  Future<void> updateQuantity(int itemId, int newQty) async {
      final currentState = state.value;
      if (currentState == null) return;
      final previousCart = currentState; 

      // Optimistic Update
      final updatedItems = currentState.items.map((item) {
        if (item.id == itemId) return item.copyWith(quantity: newQty);
        return item;
      }).toList();
      state = AsyncData(_recalculateTotal(updatedItems));

      try {
        final repo = ref.read(cartRepositoryProvider);
        if (newQty > 0) {
          await repo.updateCartItemQuantity(itemId: itemId, quantity: newQty);
        } else {
          await repo.removeCartItem(itemId);
          final itemsAfterRemove = updatedItems.where((i) => i.id != itemId).toList();
          state = AsyncData(_recalculateTotal(itemsAfterRemove));
        }
      } catch (e) {
        state = AsyncData(previousCart); // Rollback
      }
  }
  

  Future<void> removeItem(int itemId) async {
    await updateQuantity(itemId, 0);
  }

 // Di dalam class CartController

// features/cart/presentation/cart_controller.dart

// ... fungsi build, addToCart, dsb ...

  // Fungsi untuk menghapus item yang baru saja di-checkout dari server
  Future<void> clearSelectedItemsAfterCheckout() async {
    final currentState = state.value;
    if (currentState == null) return;

    // Ambil ID item keranjang (bukan product id) yang sedang dipilih
    final selectedIds = currentState.items
        .where((item) => item.isSelected)
        .map((item) => item.id)
        .toList();

    try {
      final repo = ref.read(cartRepositoryProvider);
      
      // Hapus di server satu per satu
      for (var id in selectedIds) {
        await repo.removeCartItem(id);
      }

      // Refresh state agar sinkron dengan server (mengambil cart kosong/sisa)
      ref.invalidateSelf();
    } catch (e) {
      print("Gagal membersihkan keranjang di server: $e");
      // Jika server gagal, paksa hapus secara lokal agar UI tidak membingungkan
      clearCart();
    }
  }

  // Fungsi pembersihan lokal (sebagai backup)
  void clearCart() {
    state.whenData((currentCart) {
      state = AsyncValue.data(Cart(
        cartId: currentCart.cartId, 
        items: [],
        totalPrice: 0,
        totalItems: 0,
      ));
    });
  }

}