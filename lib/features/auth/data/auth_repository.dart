import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/errors/api_exceptions.dart';
import '../../../core/network/dio_provider.dart';
import '../../../config/constants.dart';
import 'user_model.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(
    dio: ref.watch(dioProvider),
    storage: const FlutterSecureStorage(),
  );
}

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository({required Dio dio, required FlutterSecureStorage storage})
      : _dio = dio,
        _storage = storage;

  // --- 1. SIMPAN USER KE LOKAL (Dipanggil setelah login berhasil) ---
  Future<void> saveUserToLocal(User user) async {
    final sp = await SharedPreferences.getInstance();
    
    // Simpan object user lengkap
    await sp.setString('user_data', jsonEncode(user.toJson()));
    
    // Simpan token untuk Interceptor Dio
    if (user.token != null) {
      await sp.setString(AppConstants.keyToken, user.token!);
      await _storage.write(key: AppConstants.keyToken, value: user.token!);
    }
    
    // Simpan user_id secara spesifik (Sangat penting untuk fitur Cart/Transaction)
    await sp.setInt('user_id', user.id);
  }

  // --- 2. AMBIL USER DARI LOKAL ---
  Future<User?> getUserFromLocal() async {
    final sp = await SharedPreferences.getInstance();
    final jsonString = sp.getString('user_data');
    if (jsonString != null) {
      try {
        return User.fromJson(jsonDecode(jsonString));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // --- 3. LOGIN API (SUDAH DIPERBAIKI) ---
  Future<User> login({required String email, required String password}) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password
      });

      final data = response.data;
      
      if (data['success'] == true) {
        // Mapping user dari field 'user' sesuai kontrak API kamu
        final user = User.fromJson(data['user']);
        
        // Simpan langsung ke lokal agar request selanjutnya (Cart) sudah punya token
        await saveUserToLocal(user);
        
        return user;
      } else {
        throw data['message'] ?? "Login Gagal";
      }
    } catch (e) {
      throw NetworkExceptions.getErrorMessage(e);
    }
  }

  // --- 4. LOGOUT ---
  Future<void> clearUserLocal() async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear(); // Bersihkan semua data SharedPreferences
    await _storage.deleteAll(); // Bersihkan semua Secure Storage
  }

  // --- 5. FUNGSI PENDUKUNG ---
  
  Future<bool> hasToken() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString(AppConstants.keyToken);
    return token != null && token.isNotEmpty;
  }

  Future<User> getUserProfile() async {
    final user = await getUserFromLocal();
    if (user != null) return user;
    throw "Sesi berakhir, silakan login kembali";
  }

  Future<void> register({
    required String fullName, 
    required String username, 
    required String email, 
    required String password, 
    String? phoneNumber, 
    String? address
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'full_name': fullName,
        'username': username,
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
        'address': address
      });
      if (response.data['success'] != true) {
        throw response.data['message'] ?? "Gagal Registrasi";
      }
    } catch (e) {
      throw NetworkExceptions.getErrorMessage(e);
    }
  }
}