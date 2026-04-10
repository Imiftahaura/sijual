import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/errors/api_exceptions.dart';
import 'product_model.dart';

part 'product_repository.g.dart';

@riverpod
ProductRepository productRepository(ProductRepositoryRef ref) {
  return ProductRepository(ref.watch(dioProvider));
}

class ProductRepository {
  final Dio _dio;
  ProductRepository(this._dio);

  Future<List<Product>> getProducts({
  required int locationId,
  int page = 1,
  String? query,      
  int? categoryId,    
}) async {
  try {
    final Map<String, dynamic> params = {
      'location_id': locationId,
      'page': page,
      'limit': 10, 
    };

    // PERBAIKAN: Pastikan key 'query' benar-benar masuk ke params
    // Jika backend Anda menggunakan 'search', ganti 'query' menjadi 'search'
    if (query != null && query.trim().isNotEmpty) {
      params['query'] = query.trim();
      params['search'] = query.trim(); // Tambahkan ini untuk memastikan backend menerima
    }
    if (categoryId != null) {
      params['category_id'] = categoryId;
    }

    // DEBUG: Print URL untuk memastikan parameter terkirim
    print("Fetching API: /products dengan params: $params");

    final response = await _dio.get('/products', queryParameters: params);
    final dynamic responseData = response.data['data'];
    
    List listData = [];
    if (responseData is Map && responseData.containsKey('data')) {
      listData = responseData['data'];
    } else if (responseData is List) {
      listData = responseData;
    }

    return listData.map((e) => Product.fromJson(e)).toList();
  } catch (e) {
    throw NetworkExceptions.getErrorMessage(e);
  }
}

 Future<Product> getProductDetail(int id) async {
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