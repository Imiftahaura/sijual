import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/product_model.dart';
import '../data/product_repository.dart';
import '../../home/presentation/home_controller.dart';

part 'product_controller.g.dart';

// --- STRATEGI MARKETING: Rekomendasi Berdasarkan Kategori Sejenis ---
@riverpod
Future<List<Product>> recommendedProducts(
  RecommendedProductsRef ref, {
  required int? categoryId,
  required int currentProductId,
}) async {
  // Ambil data lokasi aktif agar produk sesuai cabang
  final location = await ref.watch(selectedLocationProvider.future);
  final repo = ref.read(productRepositoryProvider);

  // Ambil produk dari kategori yang sama
  final allProducts = await repo.getProducts(
    locationId: location.id,
    categoryId: categoryId,
    page: 1,
  );

  // LOGIKA STRATEGI:
  // 1. Filter agar produk yang sedang dibuka tidak muncul lagi di bawahnya
  // 2. Batasi (take) hanya 4 produk agar rapi di Grid kebawah
  return allProducts
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

// --- LOGIKA FILTER & LIST (Tetap Dipertahankan) ---
class ProductFilter {
  final String? query;
  final int? categoryId;
  const ProductFilter({this.query, this.categoryId});
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductFilter &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          categoryId == other.categoryId;
          
  @override
  int get hashCode => query.hashCode ^ categoryId.hashCode;
}

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
    return _fetchProducts(page: 1);
  }

  Future<List<Product>> _fetchProducts({required int page}) async {
    final location = await ref.watch(selectedLocationProvider.future);
    final repo = ref.read(productRepositoryProvider);
    
    // Pastikan filter.query diteruskan ke repo
    return await repo.getProducts(
      locationId: location.id,
      page: page,
      query: filter.query,      // INI ADALAH KUNCI
      categoryId: filter.categoryId,
    );
  }
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || state.isLoading) return;
    _isLoadingMore = true;
    try {
      final nextPage = _page + 1;
      final newItems = await _fetchProducts(page: nextPage);
      if (newItems.isNotEmpty) {
        _page = nextPage;
        final currentItems = state.value ?? [];
        state = AsyncData([...currentItems, ...newItems]);
      }
    } catch (e) {
      // silent
    } finally {
      _isLoadingMore = false;
    }
  }
}