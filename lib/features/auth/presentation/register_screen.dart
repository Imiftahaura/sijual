import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  bool _isObscure = true;

  // Palette Warna Premium yang Seimbang
  static const primaryBlue = Color(0xFF2C5098);
  static const primaryDark = Color(0xFF0E1A32);
  static const kunyitColor = Color(0xFFE9A717);
  static const softGrey = Color(0xFFF4F7FA);

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white, // Background dasar putih bersih
      body: Stack(
        children: [
          // 1. HEADER GRADASI (Elemen Biru Atas)
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryBlue, primaryDark],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
              ),
            ),
          ),

          // 2. CONTENT
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Judul & Subtitle (Putih di atas Biru)
                  const Text(
                    "Buat Akun Baru",
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Lengkapi detail untuk kenyamanan belanja",
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                  ),
                  const SizedBox(height: 30),

                  // 3. FORM CARD (Pusat Keseimbangan)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildSectionLabel("DATA PRIBADI"),
                          _buildProfessionalInput(
                            controller: _nameController, 
                            label: "Nama Lengkap", 
                            icon: Icons.person_outline_rounded
                          ),
                          const SizedBox(height: 14),
                          _buildProfessionalInput(
                            controller: _usernameController, 
                            label: "Username", 
                            icon: Icons.alternate_email_rounded
                          ),
                          const SizedBox(height: 14),
                          _buildProfessionalInput(
                            controller: _emailController, 
                            label: "Email", 
                            icon: Icons.email_outlined
                          ),
                          const SizedBox(height: 14),
                          _buildProfessionalInput(
                            controller: _passwordController, 
                            label: "Password", 
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            isObscure: _isObscure,
                            onToggle: () => setState(() => _isObscure = !_isObscure)
                          ),
                          
                          const SizedBox(height: 25),
                          _buildSectionLabel("ALAMAT PENGIRIMAN"),
                          _buildProfessionalInput(
                            controller: _phoneController, 
                            label: "No. WhatsApp", 
                            icon: Icons.phone_android_rounded
                          ),
                          const SizedBox(height: 14),
                          _buildProfessionalInput(
                            controller: _addressController, 
                            label: "Alamat Lengkap", 
                            icon: Icons.location_on_outlined
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(flex: 2, child: _buildProfessionalInput(controller: _cityController, label: "Kota/Kec", icon: Icons.map_outlined)),
                              const SizedBox(width: 10),
                              Expanded(flex: 1, child: _buildProfessionalInput(controller: _postalCodeController, label: "Kodepos", icon: Icons.mark_as_unread_outlined)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 4. ACTION BUTTON (Elemen Kuning & Biru Bawah)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () {}, 
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kunyitColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 6,
                              shadowColor: kunyitColor.withOpacity(0.5),
                            ),
                            child: isLoading 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("DAFTAR SEKARANG", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Sudah punya akun? ", style: TextStyle(color: Colors.grey)),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: const Text(
                                "Login di sini",
                                style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Label Seksi yang Elegan
  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12),
        child: Text(
          text,
          style: const TextStyle(color: kunyitColor, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5),
        ),
      ),
    );
  }

  // Field Input yang Profesional & Compact
  Widget _buildProfessionalInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && isObscure,
      style: const TextStyle(fontSize: 14, color: primaryDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: primaryBlue.withOpacity(0.7), size: 20),
        suffixIcon: isPassword 
          ? IconButton(icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, size: 18, color: Colors.grey), onPressed: onToggle) 
          : null,
        filled: true,
        fillColor: softGrey, // Abu-abu sangat muda agar kontras dengan card putih
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: kunyitColor, width: 1.5),
        ),
      ),
    );
  }
}