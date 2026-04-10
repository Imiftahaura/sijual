import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_provider.dart';
import '../../product/data/product_model.dart';
import 'home_models.dart'; // 1. WAJIB IMPORT INI AGAR LOCATION DIKENALI

part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) {
  return HomeRepository(ref.watch(dioProvider));
}

class HomeRepository {
  final Dio _dio;

  HomeRepository(this._dio);

  // --- HELPER: Logic Cerdas untuk Deteksi List vs Pagination ---
  List _parseListSafely(dynamic rawData) {
    if (rawData == null) return [];
    if (rawData is List) return rawData;
    if (rawData is Map<String, dynamic>) {
      if (rawData.containsKey('data') && rawData['data'] is List) {
        return rawData['data'];
      }
    }
    return [];
  }

  // 1. AMBIL HOME DATA LENGKAP (Fungsi ini yang HILANG sebelumnya)
  Future<HomeData> getHomeData(int locationId) async {
    try {
      // Kita panggil semua data secara paralel agar loading cepat
      final results = await Future.wait([
        getBanners(),
        getCategories(),
        getProducts(locationId: locationId),
      ]);

      return HomeData(
        banners: results[0] as List<BannerModel>,
        categories: results[1] as List<Category>,
        products: results[2] as List<Product>,
      );
    } catch (e) {
      // Return data kosong jika gagal, biar aplikasi gak crash
      return HomeData(banners: [], categories: [], products: []);
    }
  }

  // 2. AMBIL DAFTAR LOKASI (Fungsi "Get Location" yang kamu cari)
  Future<List<Location>> getLocations() async {
    try {
      // Jika Backend sudah siap: 
      // final response = await _dio.get('/locations');
      // return (response.data['data'] as List).map((e) => Location.fromJson(e)).toList();

      // MOCK DATA: Pakai ini dulu biar UI muncul & bisa dipilih (Aman untuk 2 hari kedepan)
      await Future.delayed(const Duration(milliseconds: 300));
      return [
        Location(id: 1, name: 'Lapas Cipinang'),
        Location(id: 2, name: 'Lapas Salemba'),
        Location(id: 3, name: 'Rutan Pondok Bambu'),
        Location(id: 4, name: 'Lapas Sukamiskin'),
      ];
    } catch (e) {
      return [];
    }
  }

  // 3. AMBIL PRODUK
  Future<List<Product>> getProducts({int? locationId}) async { // Tambah parameter locationId
    try {
      final response = await _dio.get('/products', queryParameters: {
        if (locationId != null) 'location_id': locationId
      });
      final List listData = _parseListSafely(response.data['data']);
      return listData.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      print("⚠️ Error Get Products: $e");
      return [];
    }
  }

  // 4. AMBIL KATEGORI
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      final List listData = _parseListSafely(response.data['data']);
      return listData.map((e) => Category.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // 5. AMBIL BANNER (Diperbaiki return type-nya jadi List<BannerModel>)
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await _dio.get('/banners');
      final List listData = _parseListSafely(response.data['data']);
      return listData.map((e) => BannerModel.fromJson(e)).toList();
    } catch (e) {
      // Fallback ke dummy jika API gagal
      return _dummyBanners.map((url) => BannerModel(id: 0, imageUrl: url)).toList();
    }
  }

  // Data Dummy Banner (String URL)
  final List<String> _dummyBanners = [
    'https://sijual.my.id/uploads/banner/banner3.jpeg',
    'https://sijual.my.id/uploads/banner/banner1.png',
    'https://sijual.my.id/uploads/banner/banner3.jpeg',
   
  ];
  
  // Method search produk (untuk SearchScreen)
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _dio.get('/products', queryParameters: {'search': query});
      final List listData = _parseListSafely(response.data['data']);
      return listData.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}