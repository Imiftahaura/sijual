// // lib/features/home/presentation/home_controller.dart

// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../config/constants.dart';
// import '../data/home_models.dart';
// import '../../product/data/product_model.dart';
// import '../data/home_repository.dart';

// part 'home_controller.g.dart';

// // --- Controller untuk Lokasi Terpilih ---
// @riverpod
// class SelectedLocation extends _$SelectedLocation {
//   @override
//   FutureOr<Location> build() async {
//     final sp = await SharedPreferences.getInstance();
//     final savedId = sp.getInt(AppConstants.keyUserLocation) ?? 1;
//     final savedName = sp.getString('user_location_name') ?? 'Lapas Cipinang';
//     return Location(id: savedId, name: savedName);
//   }

//   Future<void> setLocation(Location location) async {
//     state = AsyncData(location);
//     final sp = await SharedPreferences.getInstance();
//     await sp.setInt(AppConstants.keyUserLocation, location.id);
//     await sp.setString('user_location_name', location.name);
//     ref.invalidate(homeDataProvider);
//   }
// }

// // --- Provider untuk List Lokasi (Dropdown) ---
// @riverpod
// Future<List<Location>> locationList(LocationListRef ref) async {
//   return ref.watch(homeRepositoryProvider).getLocations();
// }

// // --- Provider untuk Data Home Lengkap ---
// @riverpod
// Future<HomeData> homeData(HomeDataRef ref) async {
//   final locationState = await ref.watch(selectedLocationProvider.future);
//   return ref.watch(homeRepositoryProvider).getHomeData(locationState.id);
// }

// // --- Controller Product List (UTAMA) ---
// @riverpod
// class ProductList extends _$ProductList {
//   @override
//   FutureOr<List<Product>> build() async {
//     // Agar data tidak hilang saat pindah layar
//     final link = ref.keepAlive();
    
//     // Default: Ambil semua produk
//     return ref.read(homeRepositoryProvider).getProducts();
//   }

//   // === TAMBAHKAN FUNGSI INI AGAR SEARCH SCREEN TIDAK ERROR ===
//   Future<void> search(String query) async {
//     // 1. Jika query kosong, kembalikan ke list awal (API getProducts biasa)
//     if (query.isEmpty) {
//       ref.invalidateSelf(); // Reset state ke build() awal
//       return;
//     }

//     // 2. Set loading state
//     state = const AsyncLoading();

//     // 3. Tembak API Search
//     state = await AsyncValue.guard(() => 
//       ref.read(homeRepositoryProvider).searchProducts(query)
//     );
//   }
//   // ==========================================================
// }

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/constants.dart';
import '../data/home_models.dart';
import '../../product/data/product_model.dart';
import '../data/home_repository.dart';

part 'home_controller.g.dart';

// --- 1. Controller untuk Lokasi Terpilih ---
@riverpod
class SelectedLocation extends _$SelectedLocation {
  @override
  FutureOr<Location> build() async {
    final sp = await SharedPreferences.getInstance();
    final savedId = sp.getInt(AppConstants.keyUserLocation) ?? 1;
    final savedName = sp.getString('user_location_name') ?? 'Lapas Cipinang';
    return Location(id: savedId, name: savedName);
  }

  Future<void> setLocation(Location location) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final sp = await SharedPreferences.getInstance();
      await sp.setInt(AppConstants.keyUserLocation, location.id);
      await sp.setString('user_location_name', location.name);
      return location;
    });
    // Invalidate home data agar refresh saat lokasi ganti
    ref.invalidate(homeDataProvider);
  }
}

// --- 2. Provider Mandiri untuk Kategori (UTAMA) ---
// Dengan memisahkan ini, Kategori akan tetap muncul meski data produk error
@riverpod
Future<List<Category>> categoryList(CategoryListRef ref) async {
  try {
    return await ref.watch(homeRepositoryProvider).getCategories();
  } catch (e) {
    // Jika API Kategori error/404, kita return list kosong agar UI tidak crash
    print("❌ Error Fetch Categories: $e");
    return []; 
  }
}

// --- 3. Provider untuk Data Home (Banner & Produk) ---
@riverpod
Future<HomeData> homeData(HomeDataRef ref) async {
  // Ambil lokasi terpilih dulu
  final locationState = await ref.watch(selectedLocationProvider.future);
  
  // Ambil data home berdasarkan lokasi
  return ref.watch(homeRepositoryProvider).getHomeData(locationState.id);
}

// --- 4. Provider untuk List Lokasi (Modal Picker) ---
@riverpod
Future<List<Location>> locationList(LocationListRef ref) async {
  return ref.watch(homeRepositoryProvider).getLocations();
}

// --- 5. Controller Product List (Untuk Fitur Search) ---
@riverpod
class ProductList extends _$ProductList {
  @override
  FutureOr<List<Product>> build() async {
    ref.keepAlive();
    return ref.read(homeRepositoryProvider).getProducts();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      ref.invalidateSelf();
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(homeRepositoryProvider).searchProducts(query)
    );
  }
}