import 'package:intl/intl.dart';

class AppFormatters {
  static String formatRupiah(num number) {
    // Pastikan locale id_ID terdaftar agar titik ribuan muncul benar
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }
}