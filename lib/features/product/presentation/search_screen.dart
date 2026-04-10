import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/product_model.dart';
import 'product_controller.dart';
import 'product_grid_view.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentQuery = '';

  // Fungsi untuk memproses pencarian saat tombol Enter ditekan
  void _onSearchSubmitted(String query) {
    setState(() {
      _currentQuery = query.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchFilter = ProductFilter(query: _currentQuery);
  final searchResultsAsync = ref.watch(productListProvider(searchFilter));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF2D3436)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: _onSearchSubmitted,
            decoration: InputDecoration(
              hintText: "Cari produk anyaman...",
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _currentQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchSubmitted('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),

      body: _currentQuery.isEmpty
        ? _buildInitialState() // Tampilkan Tren/Populer jika kosong
        : searchResultsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err")),
            data: (products) {
              if (products.isEmpty) return _buildEmptyState();
              
              // Tampilkan hasil pencarian murni
              return ProductGridView(
                products: products,
                filter: searchFilter,
                isScrollable: true,
              );
            },
          ),
  );
}
  Widget _buildInitialState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text("Pencarian Populer",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
        const SizedBox(height: 12),
        _buildTrendingChips(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Produk '$_currentQuery' tidak ditemukan",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingChips() {
    final List<String> trending = ["Anyaman", "Piring", "Tas Rotan", "Madu", "Batik"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        children: trending.map((item) {
          return ActionChip(
            label: Text(item),
            onPressed: () {
              _searchController.text = item;
              _onSearchSubmitted(item);
            },
          );
        }).toList(),
      ),
    );
  }
}