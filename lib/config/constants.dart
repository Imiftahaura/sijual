class AppConstants {
  // URL Server sudah benar (Live Server)
  static const String baseUrl = 'https://sijual.my.id/api/v1'; 
  
  // ⚠️ UBAH DARI 15000 JADI 60000 (60 Detik)
  static const int connectTimeout = 60000; 
  static const int receiveTimeout = 60000; 

  // Kunci Token (Pastikan AuthRepo pakai string yang sama: 'auth_token')
  static const String keyToken = 'auth_token';
  
  static const String keyCartLocal = 'cart_local_cache';
  static const String keyUserLocation = 'user_selected_location';
  static const int pageSize = 10;
}