import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart'; // Import format rupiah
import '../data/order_model.dart';

class SuccessScreen extends StatelessWidget {
  final OrderResponse order;

  const SuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              Text(
                "Pembayaran Berhasil!",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Pesanan Anda akan segera diproses.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              // TAMPILAN STRUK (BUKAN VA LAGI)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    _buildRow("ID Pesanan", order.id.toString()),
                    const Divider(height: 24),
                    _buildRow("Metode Bayar", "BCA Virtual Account"), // Mock
                    const SizedBox(height: 12),
                    _buildRow("Waktu Bayar", "Baru Saja"),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Bayar", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          AppFormatters.formatRupiah(order.totalAmount),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/transactions'); // Langsung ke history buat pantau barang
                  },
                  child: const Text("LIHAT STATUS PESANAN"),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  context.go('/home');
                }, 
                child: const Text("KEMBALI KE BERANDA")
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}