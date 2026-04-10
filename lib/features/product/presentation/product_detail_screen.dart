import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/widgets/cart_icon_badge.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../product/presentation/product_controller.dart';
import '../../product/presentation/widgets/product_card.dart';
import 'product_detail_controller.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  bool _isAdding = false;
  
  static const Color brandBlue = Color(0xFF2C5098);
  static const Color brandYellow = Color(0xFFFFD700);

  void _showSelectionSheet(BuildContext context, dynamic product, bool isDirectBuy) {
    // SECURITY: Pengecekan login dipusatkan di sini agar kedua tombol aman
    final userState = ref.read(authControllerProvider);
    if (userState.value == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Silakan login dulu untuk belanja"), 
            backgroundColor: Colors.orange, 
            behavior: SnackBarBehavior.floating
          ),
        );
        context.push('/login'); 
      }
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8), 
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl, 
                      width: 90, 
                      height: 90, 
                      fit: BoxFit.cover
                    )
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppFormatters.formatRupiah(product.price), 
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: brandBlue)
                      ),
                      Text("Stok: ${product.stock ?? 0}", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Jumlah", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFF1F3F6), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove), 
                          onPressed: _quantity > 1 ? () => setSheetState(() => _quantity--) : null
                        ),
                        Text("$_quantity", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add), 
                          onPressed: () => setSheetState(() => _quantity++)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (isDirectBuy) {
                      context.push('/transactions/checkout', extra: {
                        'product': product,
                        'quantity': _quantity
                      });
                    } else {
                      _handleAddToCart();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandBlue, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: Text(
                    isDirectBuy ? "BELI SEKARANG" : "KONFIRMASI", 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAddToCart() async {
    setState(() => _isAdding = true);
    final result = await ref.read(cartControllerProvider.notifier).addToCart(widget.productId, _quantity);
    if (mounted) {
      setState(() => _isAdding = false);
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil masuk keranjang!"), backgroundColor: brandBlue)
        );
        ref.invalidate(cartControllerProvider); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: productAsync.when(
        data: (product) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 450, 
              pinned: true, 
              elevation: 0, 
              backgroundColor: Colors.white,
              // FIX: Menghilangkan Duplicate GlobalKey dengan ValueKey unik
              leading: _buildCircleBtn(
                Icons.arrow_back_ios_new_rounded, 
                () => context.pop(), 
                uniqueKey: 'back_${widget.productId}'
              ),
              actions: [
                _buildCircleBtn(
                  null, 
                  () => context.go('/cart'), 
                  isCart: true, 
                  uniqueKey: 'cart_${widget.productId}'
                ),
                const SizedBox(width: 16)
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: CachedNetworkImage(imageUrl: product.imageUrl, fit: BoxFit.cover)
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppFormatters.formatRupiah(product.price), 
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: brandBlue)
                    ),
                    const SizedBox(height: 8),
                    Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Icon(Icons.location_on, color: brandYellow, size: 16),
                        SizedBox(width: 6),
                        Text("Lapas Kelas 1 Cipinang", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    const Text("Deskripsi Produk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      product.description ?? "Kerajinan tangan otentik.", 
                      style: const TextStyle(color: Colors.black54, height: 1.6)
                    ),
                    const SizedBox(height: 40),
                    const Divider(),
                    const SizedBox(height: 24),
                    const Text(
                      "Mungkin Kamu Suka", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: brandBlue)
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // FIX: Menggunakan SliverPadding agar grid sejajar dengan padding konten di atas
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: _buildRecommendationGrid(product.category is int ? product.category : 0),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: brandBlue)),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
      bottomNavigationBar: productAsync.asData != null 
          ? _buildShopeeBottomBar(productAsync.asData!.value) 
          : null,
    );
  }

  Widget _buildRecommendationGrid(int categoryId) {
    final recs = ref.watch(recommendedProductsProvider(categoryId: categoryId, currentProductId: widget.productId));
    return recs.when(
      data: (products) => SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, 
          childAspectRatio: 0.65, 
          mainAxisSpacing: 12, 
          crossAxisSpacing: 12
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ProductCard(
            key: ValueKey('rec_${products[index].id}'),
            product: products[index], 
            onTap: () => context.push('/product/${products[index].id}')
          ),
          childCount: products.length,
        ),
      ),
      loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  Widget _buildShopeeBottomBar(dynamic product) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, 
        border: Border(top: BorderSide(color: Colors.grey[200]!))
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: brandBlue.withOpacity(0.1), 
                borderRadius: BorderRadius.circular(8)
              ),
              child: IconButton(
                icon: const Icon(Icons.add_shopping_cart, color: brandBlue), 
                onPressed: () => _showSelectionSheet(context, product, false)
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _showSelectionSheet(context, product, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandBlue, 
                    elevation: 0, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  child: const Text(
                    "BELI SEKARANG", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleBtn(IconData? icon, VoidCallback onPressed, {bool isCart = false, String? uniqueKey}) {
    return Container(
      key: ValueKey(uniqueKey),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
      child: IconButton(
        icon: isCart 
            ? CartIconBadge(
                key: ValueKey('badge_$uniqueKey'),
                icon: Icons.shopping_cart, 
                color: brandBlue, 
                size: 20
              ) 
            : Icon(icon, color: brandBlue, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}