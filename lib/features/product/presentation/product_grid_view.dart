import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/product_model.dart';
import 'product_controller.dart';
import 'widgets/product_card.dart';

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
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // LOGIKA INFINITE SCROLL: Memuat data saat mencapai 90% scroll
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(productListProvider(widget.filter).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const Center(child: Text("Belum ada produk."));
    }

    final productListState = ref.watch(productListProvider(widget.filter));

    return GridView.builder(
      controller: widget.isScrollable ? _scrollController : null,
      shrinkWrap: !widget.isScrollable,
      physics: widget.isScrollable ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7, 
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.products.length + (productListState.isLoading ? 2 : 0),
      itemBuilder: (context, index) {
        if (index < widget.products.length) {
          return ProductCard(
            product: widget.products[index],
            onTap: () => context.push('/product/${widget.products[index].id}'),
          );
        }
        // LOADING INDICATOR DI BAWAH
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2C5098)),
          ),
        );
      },
    );
  }
}