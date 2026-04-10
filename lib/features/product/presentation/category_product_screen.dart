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
    // PANGGIL PROVIDER DENGAN FILTER SPESIFIK
    // Ini otomatis memanggil getProducts(categoryId: categoryId) di Repository
    final filter = ProductFilter(categoryId: categoryId);
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
          // PERBAIKAN: Menambahkan parameter filter agar sinkron dengan ProductGridView terbaru
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