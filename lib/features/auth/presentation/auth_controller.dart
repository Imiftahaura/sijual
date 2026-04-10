import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_model.dart';
import '../../cart/presentation/cart_controller.dart'; 

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  
  @override
  FutureOr<User?> build() async {
    // SAAT APLIKASI DIBUKA: Langsung baca memori HP
    // Ini yang bikin kamu nggak bakal disuruh login lagi
    return await ref.read(authRepositoryProvider).getUserFromLocal();
  }

  // --- LOGIN ---
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).login(
        email: email, 
        password: password
      );
      
      // PENTING: Simpan ke SharedPreferences agar permanen
      await ref.read(authRepositoryProvider).saveUserToLocal(user);
      
      // Sinkronisasi: Segarkan keranjang
      ref.invalidate(cartControllerProvider);
      
      return user;
    });
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    state = const AsyncLoading();
    try {
      // Hapus data dari API (jika ada) dan dari memori HP
      await ref.read(authRepositoryProvider).clearUserLocal();
      
      // Reset semua status
      ref.invalidate(cartControllerProvider);
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  // --- REGISTER ---
  Future<bool> register({
    required String fullName, 
    required String username, 
    required String email, 
    required String password, 
    String? phoneNumber, 
    String? address
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).register(
        fullName: fullName, 
        username: username, 
        email: email, 
        password: password, 
        phoneNumber: phoneNumber, 
        address: address
      );
      state = const AsyncData(null); 
      return true;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return false;
    }
  }
}