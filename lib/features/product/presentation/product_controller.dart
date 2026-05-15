import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/product_model.dart';
import '../data/product_repository.dart';

part 'product_controller.g.dart';

// --- STRATEGI MARKETING: Rekomendasi Berdasarkan Kategori Sejenis ---
@riverpod
Future<List<Product>> recommendedProducts(
  RecommendedProductsRef ref, {
  required int? categoryId,
  required int currentProductId,
}) async {
  final repo = ref.read(productRepositoryProvider);

  // Ambil produk halaman pertama
  final result = await repo.getProducts(page: 1);

  // LOGIKA STRATEGI:
  // 1. Filter agar produk yang sedang dibuka tidak muncul lagi di bawahnya
  // 2. Batasi (take) hanya 4 produk agar rapi di Grid kebawah
  return result.items
      .where((p) => p.id != currentProductId)
      .take(4) 
      .toList();
}

// --- PROVIDER HISTORY (Tetap Dipertahankan) ---
@Riverpod(keepAlive: true)
class ProductHistory extends _$ProductHistory {
  @override
  List<Product> build() => [];

  void addProduct(Product product) {
    final list = [...state];
    list.removeWhere((element) => element.id == product.id);
    state = [product, ...list].take(10).toList();
  }
}

// --- LOGIKA FILTER & LIST ---

/// Filter untuk menentukan mode list (semua produk / search)
class ProductFilter {
  final String? query;
  const ProductFilter({this.query});
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductFilter &&
          runtimeType == other.runtimeType &&
          query == other.query;
          
  @override
  int get hashCode => query.hashCode;
}

/// Controller utama untuk infinite scroll / lazy loading produk.
/// 
/// Konsep: Sama seperti di JavaScript yang pakai IntersectionObserver 
/// atau scroll listener untuk load batch berikutnya saat mendekati viewport.
/// Di Flutter, ini disebut "infinite scroll" / "pagination" — menggunakan 
/// ScrollController yang memanggil loadMore() saat mendekati batas scroll.
@riverpod
class ProductList extends _$ProductList {
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  FutureOr<List<Product>> build(ProductFilter filter) async {
    // Reset state setiap kali filter berubah
    _page = 1;
    _hasMore = true;
    _isLoadingMore = false;
    return _fetchProducts(page: 1);
  }

  Future<List<Product>> _fetchProducts({required int page}) async {
    final repo = ref.read(productRepositoryProvider);
    
    // Pilih endpoint berdasarkan filter
    if (filter.query != null && filter.query!.trim().isNotEmpty) {
      // Mode Search: GET /products/search?q=keyword&page=N
      final result = await repo.searchProducts(
        query: filter.query!,
        page: page,
      );
      _hasMore = result.hasMore;
      return result.items;
    } else {
      // Mode Normal: GET /products?page=N
      final result = await repo.getProducts(page: page);
      _hasMore = result.hasMore;
      return result.items;
    }
  }

  /// Dipanggil oleh ScrollController saat user mendekati akhir list.
  /// Sama seperti konsep "mendekati viewport" di JavaScript.
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    
    // Jangan load more jika data awal masih loading
    if (state is AsyncLoading) return;
    
    _isLoadingMore = true;
    try {
      final nextPage = _page + 1;
      final newItems = await _fetchProducts(page: nextPage);
      if (newItems.isNotEmpty) {
        _page = nextPage;
        final currentItems = state.value ?? [];
        state = AsyncData([...currentItems, ...newItems]);
      } else {
        // API return empty list = tidak ada lagi data
        _hasMore = false;
      }
    } catch (e) {
      // Jangan crash, cukup log error
      print("⚠️ Error loadMore: $e");
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Getter untuk UI mengetahui apakah masih ada data selanjutnya
  bool get hasMore => _hasMore;

  /// Getter untuk UI mengetahui apakah sedang loading batch berikutnya
  bool get isLoadingMore => _isLoadingMore;
}