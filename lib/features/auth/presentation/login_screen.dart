import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // Palette Premium & Seimbang
  static const Color primaryBlue = Color(0xFF2C5098);
  static const Color primaryDark = Color(0xFF0E1A32);
  static const Color accentGold = Color(0xFFE9A717);
  static const Color fieldGrey = Color(0xFFF8FAFC);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AsyncLoading;

    // Listener untuk Handle Navigasi Sukses atau Error
    ref.listen(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString().replaceAll('Exception:', '')),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (next is AsyncData && next.value != null) {
        context.go('/home');
      }
    });

  return PopScope(
  canPop: false, // Menahan tombol back agar tidak exit aplikasi
  onPopInvoked: (didPop) {
    // didPop akan bernilai true jika canPop di atas diset true.
    if (didPop) return;

    // Jika sedang loading login, kunci tombol back agar tidak interupsi proses
    if (isLoading) return;

    // LOGIC UTAMA: Paksa navigasi ke Home alih-alih keluar aplikasi
    Future.microtask(() {
      if (context.mounted) {
        context.go('/home'); // Arahkan ke rute utama aplikasi kamu
      }
    });
  },
  
    // ... sisa kode body kamu tetap sama
      child: Scaffold(
        body: Stack(
          children: [
            // 1. BACKGROUND GRADASI FULL
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [primaryBlue, primaryDark],
                ),
              ),
            ),

            // 2. TEKSTUR BULETAN DESIGN (Abstract Decoration)
            Positioned(
              top: -60,
              left: -40,
              child: _buildBubble(220, Colors.white.withOpacity(0.06)),
            ),
            Positioned(
              bottom: 120,
              right: -50,
              child: _buildBubble(180, Colors.white.withOpacity(0.08)),
            ),
            Positioned(
              top: 300,
              right: 20,
              child: _buildBubble(60, Colors.white.withOpacity(0.04)),
            ),
            Positioned(
              bottom: -30,
              left: 40,
              child: _buildBubble(120, Colors.white.withOpacity(0.05)),
            ),

            // 3. MAIN CONTENT
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // FLOATING CARD (Kotak Lebar di Tengah)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 45),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo Box Premium
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: fieldGrey,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Image.asset(
                                'assets/icons/sicon.png',
                                height: 55,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.shopping_bag_rounded, size: 50, color: primaryBlue),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "WELCOME BACK",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 5,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Fields Input
                            _buildInput(
                              controller: _emailController,
                              hint: "Email Address",
                              icon: Icons.email_outlined,
                              enabled: !isLoading,
                              validator: (val) => (val == null || val.isEmpty) ? "Email wajib diisi" : null,
                            ),
                            const SizedBox(height: 18),
                            _buildInput(
                              controller: _passwordController,
                              hint: "Password",
                              icon: Icons.lock_open_rounded,
                              isPassword: true,
                              isObscure: !_isPasswordVisible,
                              enabled: !isLoading,
                              onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                              validator: (val) => (val == null || val.length < 6) ? "Minimal 6 karakter" : null,
                            ),

                            const SizedBox(height: 40),

                            // Realist & Elegant Button (Tidak Terlalu Gede)
                            SizedBox(
                              width: 170,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : () {
                                  if (_formKey.currentState!.validate()) {
                                    ref.read(authControllerProvider.notifier).login(
                                      _emailController.text.trim(),
                                      _passwordController.text,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                child: isLoading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text("SIGN IN", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    // Footer
                    GestureDetector(
                      onTap: () => isLoading ? null : context.push('/register'),
                      child: const Text(
                        "Don't have an account? Register",
                        style: TextStyle(
                          color: Colors.white70, 
                          fontSize: 14, 
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.5
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Tekstur Buletan
  Widget _buildBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  // Widget Helper untuk Field Input
  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isObscure = false,
    bool enabled = true,
    VoidCallback? onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && isObscure,
      enabled: enabled,
      style: const TextStyle(fontSize: 14, color: primaryDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 13),
        prefixIcon: Icon(icon, color: primaryBlue.withOpacity(0.5), size: 20),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(isObscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: Colors.grey), 
              onPressed: onToggle
            ) 
          : null,
        filled: true,
        fillColor: fieldGrey,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentGold, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}