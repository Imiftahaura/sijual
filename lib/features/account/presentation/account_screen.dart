import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../../auth/presentation/auth_controller.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    
    const brandBlue = Color(0xFF2C5098);
    const softGrey = Color(0xFFF8F9FB);
    const textDark = Color(0xFF2D3436);

    return Scaffold(
      backgroundColor: softGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0, 
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: brandBlue)),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (user) {
          final bool isLoggedIn = user != null;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Header Modern Minimalis
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24), 
                  child: Row(
                    children: [
                      _buildAvatar(isLoggedIn),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLoggedIn ? (user.name ?? "Pengguna Sijual") : "Selamat Datang",
                              style: const TextStyle(
                                color: textDark, 
                                fontSize: 18, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isLoggedIn ? "Lihat profil saya" : "Masuk untuk belanja lebih mudah",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),
                    _buildTrustPanel(brandBlue),
                    const SizedBox(height: 24),
                    
                    // REVISI: Navigasi ke sub-route yang benar
                    _buildSectionLabel(
                      "Pesanan Saya", 
                      () => context.push('/account/transaction-history', extra: 'all')
                    ),
                    _buildOrderStatusCard(context),

                    const SizedBox(height: 24),
                    _buildPromoCard(brandBlue),
                    const SizedBox(height: 24),
                    _buildSectionLabel("Pengaturan & Layanan", null),
                    _buildMenuBox([
                      _buildMenuItem(
                        context, 
                        Icons.settings_outlined, 
                        textDark, 
                        "Pengaturan Akun", 
                        () => isLoggedIn ? context.push('/edit-profile') : context.push('/login')
                      ),
                      _buildMenuItem(
                        context, 
                        Icons.support_agent_rounded, 
                        Colors.blue.shade600, 
                        "Pusat Bantuan (WhatsApp)", 
                        () => _launchURL('https://wa.me/628123456789')
                      ),
                      _buildMenuItem(
                        context, 
                        Icons.verified_outlined, 
                        brandBlue, 
                        "Tentang Sijual v2.0", 
                        () {}
                      ),
                    ]),

                    const SizedBox(height: 32),
                    _buildLogoutButton(context, ref, isLoggedIn),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "Versi 2.0.1",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAvatar(bool isLoggedIn) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2C5098).withOpacity(0.15), width: 1.5),
      ),
      child: const CircleAvatar(
        radius: 30, 
        backgroundColor: Color(0xFFF1F3F6),
        child: Icon(Icons.person_rounded, size: 32, color: Color(0xFF2C5098)),
      ),
    );
  }

  Widget _buildTrustPanel(Color brandBlue) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _trustItem(Icons.verified_user_rounded, "Terverifikasi", Colors.green),
          _trustItem(Icons.shield_rounded, "Belanja Aman", brandBlue),
          _trustItem(Icons.history_rounded, "Respon Cepat", Colors.orange),
        ],
      ),
    );
  }

  Widget _trustItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
      ],
    );
  }

  Widget _buildOrderStatusCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _orderIcon(context, Icons.account_balance_wallet_outlined, "Bayar", "pending"),
          _orderIcon(context, Icons.inventory_2_outlined, "Proses", "packed"),
          _orderIcon(context, Icons.local_shipping_outlined, "Kirim", "shipping"),
          _orderIcon(context, Icons.check_circle_outline, "Selesai", "delivered"),
        ],
      ),
    );
  }

  Widget _orderIcon(BuildContext context, IconData icon, String label, String status) {
    return InkWell(
      onTap: () => context.push('/account/transaction-history', extra: status),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2C5098).withOpacity(0.8), size: 24), 
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF2D3436))
          ),
          if (onTap != null)
            InkWell(
              onTap: onTap,
              child: const Text(
                "Lihat Semua",
                style: TextStyle(fontSize: 13, color: Color(0xFF2C5098), fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: Colors.white, size: 36),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Program Loyalitas Sijual",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  "Kumpulkan poin dan dapatkan diskon menarik!",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildMenuBox(List<Widget> items) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, Color color, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: color, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref, bool isLoggedIn) {
    return SizedBox(
      width: double.infinity,
      height: 46, 
      child: TextButton(
        onPressed: () {
          if (isLoggedIn) {
            ref.read(authControllerProvider.notifier).logout();
          } else {
            context.go('/login');
          }
        },
        style: TextButton.styleFrom(
          foregroundColor: isLoggedIn ? Colors.red.shade600 : Colors.white,
          backgroundColor: isLoggedIn ? Colors.red.shade50 : const Color(0xFF2C5098),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          isLoggedIn ? "Keluar dari Akun" : "Masuk ke Akun", 
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}