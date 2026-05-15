import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'product_controller.dart'; // Import ProductFilter & Provider
import 'product_grid_view.dart';  // Import GridView yang sudah ada

class CategoryProductScreen extends ConsumerWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProductScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gunakan search query dengan nama kategori untuk filter produk
    // API: GET /products/search?q=categoryName&page=1
    final filter = ProductFilter(query: categoryName);
    final productState = ref.watch(productListProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName), // Judul sesuai nama kategori yg diklik
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: productState.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada produk di kategori $categoryName", 
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          // PERBAIKAN: ProductGridView dengan infinite scroll
          return ProductGridView(
            products: products, 
            filter: filter, 
            isScrollable: true,
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF2C5098)),
        ),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}