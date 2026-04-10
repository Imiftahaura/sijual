import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/widgets/cart_icon_badge.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF2C5098);
    const Color brandYellow = Color(0xFFFFD700);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: _goBranch,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: brandBlue, // Warna seleksi utama Biru
            unselectedItemColor: Colors.grey[400],
            selectedFontSize: 10,
            unselectedFontSize: 10,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded, color: brandYellow),
                label: 'Beranda',
              ),
              const BottomNavigationBarItem(
                icon: CartIconBadge(icon: Icons.shopping_cart_outlined),
                activeIcon: CartIconBadge(icon: Icons.shopping_cart_rounded, color: brandYellow),
                label: 'Keranjang',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none_rounded),
                // Spesifik warna kuning hanya untuk notifikasi
                activeIcon: Icon(Icons.notifications_rounded, color: brandYellow), 
                label: 'Notifikasi',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded, color: brandYellow),
                label: 'Akun',
              ),
            ],
          ),
        ),
      ),
    );
  }
}