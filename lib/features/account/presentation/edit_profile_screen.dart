import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/data/user_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final bool isFocusAddress;
  const EditProfileScreen({super.key, this.isFocusAddress = false});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  final _addressFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Ambil data user yang sedang login saat ini
    final user = ref.read(authControllerProvider).value;
    
    _nameController = TextEditingController(text: user?.name);
    _phoneController = TextEditingController(text: user?.phoneNumber);
    _addressController = TextEditingController(text: user?.address);

    // Jika dipanggil dari Checkout, otomatis fokus ke input alamat
    if (widget.isFocusAddress) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_addressFocusNode);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final oldUser = ref.read(authControllerProvider).value!;
      
      // Buat object user baru dengan data terupdate
      final updatedUser = User(
        id: oldUser.id,
        name: _nameController.text.trim(),
        email: oldUser.email,
        username: oldUser.username,
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        token: oldUser.token,
        role: oldUser.role,
      );

      // SIMPAN KE LOKAL (Agar persistent saat app ditutup)
      await ref.read(authRepositoryProvider).saveUserToLocal(updatedUser);
      
      // Refresh AuthController agar semua UI yang memantau user (termasuk Checkout) terupdate
      ref.invalidate(authControllerProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil & Alamat Berhasil Disimpan!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFocusAddress ? "Alamat Pengiriman" : "Edit Profil"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Informasi Kontak",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nama Lengkap",
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? "Nama tidak boleh kosong" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Nomor Telepon",
                prefixIcon: Icon(Icons.phone_android_outlined),
                border: OutlineInputBorder(),
                hintText: "Contoh: 08123456789",
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value == null || value.isEmpty ? "Nomor telepon tidak boleh kosong" : null,
            ),
            const SizedBox(height: 24),
            const Text(
              "Alamat Pengiriman",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _addressController,
              focusNode: _addressFocusNode,
              decoration: const InputDecoration(
                labelText: "Detail Alamat",
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: Icon(Icons.location_on_outlined),
                ),
                border: OutlineInputBorder(),
                hintText: "Tuliskan alamat lengkap Anda di sini...",
              ),
              maxLines: 4,
              validator: (value) => value == null || value.isEmpty ? "Alamat tidak boleh kosong" : null,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              child: const Text(
                "SIMPAN PERUBAHAN",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}