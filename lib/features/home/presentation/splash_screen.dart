import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/data/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final repo = ref.read(authRepositoryProvider);
    final hasToken = await repo.hasToken();

    // Sesuai permintaanmu, arahkan ke home (atau ke login jika hasToken false nanti)
    if (hasToken) {
      context.go('/home');
    } else {
      context.go('/home'); // Sementara ke home dulu sesuai logic aslimu
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background putih bersih
      body: Stack(
        children: [
          // 1. LOGO & NAMA (TENGAH)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Agar column tidak makan space layar
              children: [
                // Logo Sicon
                Image.asset(
                  'assets/icons/sicon.png',
                  width: 120, // Sesuaikan ukuran logo
                  height: 120,
                ),
                const SizedBox(height: 16), // Jarak antara logo dan nama
                // Gambar Nama SiJual
                Image.asset(
                  'assets/icons/name.png',
                  width: 150, // Dibuat lebih kecil sesuai permintaanmu
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),

          // 2. LOADING INDICATOR (DI BAWAH LOGO)
          Positioned(
            left: 0,
            right: 0,
            bottom: 150, // Posisi loading agak di bawah tengah
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor, // Pakai warna tema aplikasi
                strokeWidth: 3,
              ),
            ),
          ),

          // 3. COPYRIGHT (PALING BAWAH)
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Column(
              children: [
                const Text(
                  "SiJual 2.0",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "copyright by fasilkom ibik 1957",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}