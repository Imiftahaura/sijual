import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/errors/api_exceptions.dart';
import 'product_model.dart';

part 'product_repository.g.dart';

/// Model untuk menampung hasil pagination dari API
class PaginatedResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginatedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}

@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  return ProductRepository(ref.watch(dioProvider));
}

class ProductRepository {
  final Dio _dio;
  ProductRepository(this._dio);

  /// Ambil semua produk dengan pagination
  /// API: GET /products?page=1
  Future<PaginatedResult<Product>> getProducts({int page = 1}) async {
    try {
      final response = await _dio.get('/products', queryParameters: {
        'page': page,
      });

      final responseBody = response.data;
      final List listData = responseBody['data'] ?? [];
      final pagination = responseBody['pagination'];

      final products = listData.map((e) => Product.fromJson(e)).toList();

      return PaginatedResult(
        items: products,
        total: pagination?['total'] ?? products.length,
        page: pagination?['page'] ?? page,
        limit: pagination?['limit'] ?? 20,
        totalPages: pagination?['totalPages'] ?? 1,
      );
    } catch (e) {
      throw NetworkExceptions.getErrorMessage(e);
    }
  }

  /// Cari produk dengan pagination
  /// API: GET /products/search?q=keyword&page=1
  Future<PaginatedResult<Product>> searchProducts({
    required String query,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get('/products/search', queryParameters: {
        'q': query.trim(),
        'page': page,
      });

      final responseBody = response.data;
      final List listData = responseBody['data'] ?? [];
      final pagination = responseBody['pagination'];

      final products = listData.map((e) => Product.fromJson(e)).toList();

      return PaginatedResult(
        items: products,
        total: pagination?['total'] ?? products.length,
        page: pagination?['page'] ?? page,
        limit: pagination?['limit'] ?? 20,
        totalPages: pagination?['totalPages'] ?? 1,
      );
    } catch (e) {
      throw NetworkExceptions.getErrorMessage(e);
    }
  }

  /// Ambil detail produk berdasarkan id_product
  /// API: GET /products/:id_product
  Future<Product> getProductDetail(dynamic id) async {
    try {
      final response = await _dio.get('/products/$id');

      // Jika server mengembalikan data di dalam field 'data', ambil itu. 
      // Jika tidak, ambil langsung dari root response.data
      final json = response.data['data'] ?? response.data;

      if (json == null) throw "Data produk tidak ditemukan";

      return Product.fromJson(json);
    } catch (e) {
      throw NetworkExceptions.getErrorMessage(e);
    }
  }
}