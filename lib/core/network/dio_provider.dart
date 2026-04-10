import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/constants.dart';
import '../../features/auth/presentation/auth_controller.dart';

part 'dio_provider.g.dart';

// Logger untuk mencetak log yang rapi di console
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
    printEmojis: true,
  ),
);

@riverpod
Dio dio(DioRef ref) {
  final options = BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
    receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  final dio = Dio(options);

  // 1. Interceptor untuk menangani Log secara otomatis (Sangat membantu untuk debug Error 500)
  dio.interceptors.add(LogInterceptor(
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
    logPrint: (obj) => logger.d(obj), // Mencetak log ke logger premium
  ));

  // 2. Interceptor Utama untuk Auth & Error Handling
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Logika Pengambilan Token yang Kuat (Strong Fallback)
        final user = ref.read(authControllerProvider).value;
        String? token = user?.token;

        // Jika memori kosong (cold start), paksa baca langsung dari SharedPreferences
        if (token == null || token.isEmpty) {
          final sp = await SharedPreferences.getInstance();
          token = sp.getString(AppConstants.keyToken);
        }

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          logger.i("🛠️ [Dio] Request terotorisasi. Token ditemukan.");
        } else {
          logger.w("⚠️ [Dio] Request tanpa Token - Pastikan endpoint ini publik.");
        }

        return handler.next(options);
      },
      
      onResponse: (response, handler) {
        // Bisa ditambahkan logika global untuk response tertentu jika perlu
        return handler.next(response);
      },
      
      onError: (DioException e, handler) {
        // Penanganan Otomatis Logout jika Sesi Habis (401)
        if (e.response?.statusCode == 401) {
          logger.e("🚨 [Dio] Sesi Kadaluarsa (401). Menghapus data login...");
          ref.read(authControllerProvider.notifier).logout();
        }

        // Memberikan info lebih detail jika terjadi Error 500
        if (e.response?.statusCode == 500) {
          logger.e("🔥 [Dio] Server Error (500). Periksa payload request atau logika backend.");
        }
        
        return handler.next(e);
      },
    ),
  );

  return dio;
}