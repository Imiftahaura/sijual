// lib/core/utils/widgets/cart_icon_badge.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/cart/presentation/cart_controller.dart';

class CartIconBadge extends ConsumerWidget {
  final IconData icon;
  final Color? color;
  final double size; // Menambahkan definisi parameter size

  const CartIconBadge({
    super.key,
    this.icon = Icons.shopping_cart_outlined,
    this.color,
    this.size = 24, // Inisialisasi default size
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartControllerProvider);
    // Definisi warna Kuning Kunyit Sijual agar lebih hidup
    const Color brandYellow = Color(0xFFFFD700); 

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: size, color: color),
        
        // Munculkan badge hanya jika ada item di keranjang
        if (cartState.hasValue && cartState.value!.totalItems > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: brandYellow, // Menggunakan warna kuning kunyit
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 14,
                minHeight: 14,
              ),
              child: Text(
                cartState.value!.totalItems > 99 
                    ? '99+' 
                    : '${cartState.value!.totalItems}',
                style: const TextStyle(
                  color: Colors.black, // Teks hitam agar kontras dengan kuning
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}