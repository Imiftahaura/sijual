import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'home_controller.dart';
import '../../product/presentation/product_grid_view.dart';
import '../../product/presentation/product_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const Color brandBlue = Color(0xFF2C5098);
  static const Color brandYellow = Color(0xFFFFD700);
  static const Color bgGrey = Color(0xFFF1F3F6);

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: bgGrey, 
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: false,
            expandedHeight: 80,
            title: const Text(
              "Sijual",
              style: TextStyle(
                color: brandBlue, 
                fontWeight: FontWeight.w900, 
                fontSize: 24,
                letterSpacing: -0.8,
              ),
            ),
            actions: [
              _buildActionButton(Icons.chat_bubble_outline_rounded, () {}),
              // IKON NOTIFIKASI DI SINI SUDAH DIHAPUS
              const SizedBox(width: 16),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _buildSearchBar(context),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Kategori Pilihan"),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildCategoryList(_getDummyCategories()),
                  ),
                ],
              ),
            ),
          ),

          homeDataAsync.when(
            data: (data) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionHeader("Rekomendasi Untukmu"),
                  const SizedBox(height: 12),
                  ProductGridView(
                    products: data.products,
                    filter: const ProductFilter(),
                    isScrollable: false,
                  ),
                ]),
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 50),
                child: Center(child: CircularProgressIndicator(color: brandBlue)),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(child: Center(child: Text("Error: $e"))),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        readOnly: true,
        onTap: () => context.push('/search'),
        decoration: const InputDecoration(
          hintText: "Cari kerajinan lokal...",
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: Icon(Icons.search_rounded, color: brandBlue, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: brandBlue, size: 22),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4, height: 16, 
          decoration: BoxDecoration(color: brandYellow, borderRadius: BorderRadius.circular(2))
        ),
        const SizedBox(width: 8),
        Text(
          title, 
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))
        ),
      ],
    );
  }

  Widget _buildCategoryList(List<Map<String, dynamic>> categories) {
    return SizedBox(
      height: 75,
      child: Center(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final String name = categories[index]['name']!;
            final int id = categories[index]['id']!;
            return InkWell(
              onTap: () => context.push('/category/$id', extra: name),
              child: SizedBox(
                width: 72,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 48, width: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(child: Icon(Icons.category_rounded, color: brandBlue)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getDummyCategories() {
    return [
      {'id': 1, 'name': 'Anyaman'},
      {'id': 2, 'name': 'Makanan'},
      {'id': 3, 'name': 'Pakaian'},
      {'id': 4, 'name': 'Minuman'},
      {'id': 5, 'name': 'Lainnya'},
    ];
  }
}