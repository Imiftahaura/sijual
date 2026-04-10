import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48.0, // Ukuran tinggi yang lebih modern/ramping
    this.borderRadius = 12.0, // Disamakan dengan radius SearchBar/Category
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    // Definisi warna brand Sijual
    const Color brandBlue = Color(0xFF2C5098);
    const Color brandYellow = Color(0xFFFFD700);

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          // Gunakan Biru Sijual sebagai default
          backgroundColor: backgroundColor ?? brandBlue,
          // Gunakan Putih atau Kuning sebagai aksen teks
          foregroundColor: textColor ?? Colors.white,
          disabledBackgroundColor: const Color(0xFFE1E3E6),
          disabledForegroundColor: Colors.grey[500],
          elevation: 0,
          // Efek splash saat ditekan agar terasa hidup
          splashFactory: InkRipple.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 14, // Sedikit diperkecil agar lebih mature
                  fontWeight: FontWeight.w800, // Tebal (Bold) agar tegas
                  letterSpacing: 0.8, // Spasi antar huruf untuk kesan premium
                ),
              ),
      ),
    );
  }
}