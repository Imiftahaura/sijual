import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../product/presentation/product_controller.dart';
import '../../product/presentation/widgets/product_card.dart';
import 'cart_controller.dart';
import 'widgets/cart_item_tile.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  // Palette Warna Dewasa Sijual
  static const Color brandBlue = Color(0xFF2C5098);
  static const Color brandYellow = Color(0xFFFFD700);

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: const [
              Icon(Icons.lock_outline, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text("Akses Terbatas", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
              children: [
                const TextSpan(text: "Anda belum login. Silakan "),
                TextSpan(
                  text: "Login Sekarang",
                  style: const TextStyle(
                    color: brandBlue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pop(ctx);
                      context.push('/login');
                    },
                ),
                const TextSpan(text: " untuk melanjutkan proses checkout."),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal", style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
          ],
        );
      },
    );
  }

  void _showSelectProductDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Pilih minimal satu produk untuk di-checkout", style: TextStyle(fontSize: 12)),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartControllerProvider);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text("Keranjang Belanja", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: brandBlue,
        elevation: 0.5,
        centerTitle: true,
        toolbarHeight: 50, // AppBar lebih ramping
      ),
      body: cartState.when(
        data: (cart) {
          if (cart.items.isEmpty) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Icon(Icons.shopping_cart_outlined, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text("Keranjang belanjamu masih kosong", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("Yuk isi dengan barang-barang impianmu!", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => context.go('/home'),
                      style: ElevatedButton.styleFrom(backgroundColor: brandBlue, foregroundColor: Colors.white, elevation: 0),
                      child: const Text("Mulai Belanja", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  _buildRecommendationSection(context),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(cartControllerProvider.notifier).refreshCart(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return CartItemTile(
                  item: item,
                  isReadOnly: false,
                  onToggle: (val) => ref.read(cartControllerProvider.notifier).toggleSelection(item.id),
                  onUpdateQty: (newQty) => ref.read(cartControllerProvider.notifier).updateQuantity(item.id, newQty),
                  onRemove: () => _confirmDelete(context, ref, item.id),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: brandBlue)),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      bottomNavigationBar: _buildBottomSummary(context, ref, cartState, authState),
    );
  }

  Widget _buildRecommendationSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Rekomendasi untukmu", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: brandBlue)),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, child) {
              final productAsync = ref.watch(productListProvider(const ProductFilter()));
              return productAsync.when(
                data: (products) {
                  final recommendations = products.take(5).toList();
                  if (recommendations.isEmpty) return const SizedBox.shrink();
                  return SizedBox(
                    height: 220, // Grid lebih rapat
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendations.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final product = recommendations[index];
                        return SizedBox(
                          width: 140, 
                          child: ProductCard(
                            product: product,
                            onTap: () => context.push('/product/${product.id}'),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int itemId) {
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Hapus item?", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey, fontSize: 13))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(cartControllerProvider.notifier).removeItem(itemId);
            }, 
            child: const Text("Hapus", style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold))
          ),
        ],
      )
    );
  }

  Widget _buildBottomSummary(BuildContext context, WidgetRef ref, AsyncValue cartState, AsyncValue authState) {
    return cartState.maybeWhen(
      data: (cart) {
        if (cart.items.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24), // Padding bawah disesuaikan untuk safe area
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
          ),
          child: Row(
            children: [
              Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: cart.items.isNotEmpty && cart.items.every((e) => e.isSelected),
                  activeColor: brandBlue,
                  onChanged: (val) => ref.read(cartControllerProvider.notifier).toggleAll(val ?? false),
                ),
              ),
              const Text("Semua", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Total Harga", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(
                    AppFormatters.formatRupiah(cart.totalPrice.toDouble()),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: brandBlue),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 38, // Button ramping
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandYellow, 
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: cart.totalPrice <= 0
                      ? null 
                      : () {
                          if (authState.value == null) {
                            _showLoginRequiredDialog(context);
                          } else {
                            context.push('/transactions/checkout');
                          }
                        },
                  child: Text("CHECKOUT (${cart.selectedCount})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}