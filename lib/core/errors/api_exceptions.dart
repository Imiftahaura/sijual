
import 'package:dio/dio.dart';

class NetworkExceptions {
  static String getErrorMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.cancel:
          return "Permintaan ke server dibatalkan";
        case DioExceptionType.connectionTimeout:
          return "Waktu koneksi habis. Cek sinyal internet Anda";
        case DioExceptionType.receiveTimeout:
          return "Server butuh waktu lama untuk merespons";
        case DioExceptionType.sendTimeout:
          return "Gagal mengirim data ke server";
        case DioExceptionType.connectionError:
          return "Tidak ada koneksi internet. Pastikan data/wifi aktif";
        case DioExceptionType.badResponse:
          return _handleBadResponse(error.response?.statusCode, error.response?.data);
        case DioExceptionType.unknown:
          if (error.error.toString().contains("SocketException")) {
            return "Tidak ada koneksi internet";
          }
          return "Terjadi kesalahan yang tidak diketahui";
        default:
          return "Terjadi kesalahan jaringan";
      }
    } else {
      return "Terjadi kesalahan sistem: $error";
    }
  }

  static String _handleBadResponse(int? statusCode, dynamic data) {
   
    String serverMessage = "";
    if (data is Map && data.containsKey('message')) {
      serverMessage = data['message'];
    }

    switch (statusCode) {
      case 400:
        return serverMessage.isNotEmpty ? serverMessage : "Permintaan tidak valid";
      case 401:
        return "Sesi habis. Silakan login kembali"; 
      case 403:
        return "Anda tidak memiliki akses";
      case 404:
        return "Data tidak ditemukan";
      case 500:
        return "Server sedang bermasalah. Coba lagi nanti";
      default:
        return "Terjadi kesalahan (Kode: $statusCode)";
    }
  }
}