import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF2C5098);
    const brandYellow = Color(0xFFFFD700);
    const bgGrey = Color(0xFFF6F7F9);

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        title: const Text(
          "Notifikasi",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), // Ukuran standar mobile
        ),
        backgroundColor: Colors.white,
        foregroundColor: brandBlue,
        elevation: 0.5,
        centerTitle: true,
        toolbarHeight: 56, // Tinggi standar AppBar Android/iOS
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildCategoryHeader(Icons.campaign_rounded, "Info Sistem", Colors.blue.shade700),
          _buildNotificationItem(
            icon: Icons.system_update_rounded,
            iconBgColor: Colors.blue.shade50,
            iconColor: Colors.blue.shade700,
            title: "Update Aplikasi",
            desc: "Sijual v2.0 kini lebih responsif dan aman! Nikmati pengalaman belanja lebih lancar dan fitur pencarian baru.",
            time: "Hari ini, 10:30",
            isUnread: true,
          ),
          const Divider(height: 1, indent: 72), // Indent disesuaikan dengan ukuran ikon baru
          
          _buildCategoryHeader(Icons.local_offer_rounded, "Promo & Diskon", brandYellow),
          _buildNotificationItem(
            icon: Icons.shopping_bag_rounded,
            iconBgColor: const Color(0xFFFFF9E6),
            iconColor: brandYellow,
            title: "Promo Kerajinan Lokal",
            desc: "Diskon hingga 50% untuk produk anyaman minggu ini. Stok terbatas, serbu sekarang!",
            time: "Kemarin, 15:45",
            isUnread: false,
          ),
          const Divider(height: 1, indent: 72),

          _buildNotificationItem(
            icon: Icons.wallet_giftcard_rounded,
            iconBgColor: Colors.pink.shade50,
            iconColor: Colors.pink,
            title: "Voucher Pengguna Baru",
            desc: "Klaim voucher potongan ongkir Rp10.000 khusus untukmu hari ini. Berlaku untuk semua produk.",
            time: "2 hari lalu",
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(IconData icon, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12), // Jarak lebih lega agar enak dilihat
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade600,
              fontSize: 12, // Ditingkatkan dari 10
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String desc,
    required String time,
    bool isUnread = false,
  }) {
    return Container(
      color: isUnread ? const Color(0xFF2C5098).withOpacity(0.04) : Colors.white,
      padding: const EdgeInsets.all(16), // Padding standar untuk kenyamanan tap
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container Ikon yang lebih proporsional
          Container(
            padding: const EdgeInsets.all(12), // Meningkat dari 8
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24), // Meningkat dari 20
          ),
          const SizedBox(width: 16), // Jarak antar elemen lebih lebar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                        fontSize: 15, // Ditingkatkan dari 13
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    if (isUnread)
                      const CircleAvatar(
                        radius: 4, // Sedikit lebih besar agar terlihat
                        backgroundColor: Colors.red,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  maxLines: 3, 
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14, // Ditingkatkan dari 12 (Standar pembacaan mobile)
                    color: Colors.black.withOpacity(0.75),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12, // Ditingkatkan dari 10
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}