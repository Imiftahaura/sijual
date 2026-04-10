import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/product_model.dart';
import '../data/product_repository.dart';

part 'product_detail_controller.g.dart';

@riverpod
Future<Product> productDetail(ProductDetailRef ref, int productId) async {
  // Ambil repository produk
  final repo = ref.watch(productRepositoryProvider);
  
  // Ambil detail asli dari server
  return repo.getProductDetail(productId);
}