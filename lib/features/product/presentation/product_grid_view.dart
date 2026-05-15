import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/product_model.dart';
import 'product_controller.dart';
import 'widgets/product_card.dart';

/// Widget Grid produk dengan infinite scroll.
/// 
/// Cara kerja (mirip JavaScript IntersectionObserver):
/// - ScrollController mendeteksi posisi scroll
/// - Saat user scroll mendekati 80% dari batas bawah (viewport threshold),
///   otomatis memanggil loadMore() untuk fetch batch data selanjutnya
/// - Loading indicator muncul di bawah saat sedang fetch
/// - Berhenti otomatis saat tidak ada data lagi (hasMore = false)
class ProductGridView extends ConsumerStatefulWidget {
  final List<Product> products;
  final bool isScrollable; 
  final ProductFilter filter;

  const ProductGridView({
    super.key, 
    required this.products, 
    this.isScrollable = false,
    required this.filter,
  });

  @override
  ConsumerState<ProductGridView> createState() => _ProductGridViewState();
}

class _ProductGridViewState extends ConsumerState<ProductGridView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.isScrollable) {
      _scrollController.addListener(_onScroll);
    }
  }

  void _onScroll() {
    // LOGIKA INFINITE SCROLL: 
    // Memuat batch berikutnya saat scroll mencapai 80% dari maxScrollExtent.
    // Ini equivalent dengan "mendekati viewport" di JavaScript.
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(productListProvider(widget.filter).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const Center(child: Text("Belum ada produk."));
    }

    // Ambil notifier untuk cek hasMore
    final notifier = ref.read(productListProvider(widget.filter).notifier);
    final hasMore = notifier.hasMore;

    // Hitung total item: produk + 1 slot loading indicator (jika masih ada data)
    final itemCount = widget.products.length + (hasMore ? 1 : 0);

    return GridView.builder(
      controller: widget.isScrollable ? _scrollController : null,
      shrinkWrap: !widget.isScrollable,
      physics: widget.isScrollable 
          ? const BouncingScrollPhysics() 
          : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7, 
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Item produk biasa
        if (index < widget.products.length) {
          return ProductCard(
            product: widget.products[index],
            onTap: () => context.push('/product/${widget.products[index].id}'),
          );
        }
        // LOADING INDICATOR DI BAWAH (slot terakhir)
        // Ini akan terlihat saat user scroll ke bawah mendekati akhir list
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(
              strokeWidth: 2, 
              color: Color(0xFF2C5098),
            ),
          ),
        );
      },
    );
  }
}