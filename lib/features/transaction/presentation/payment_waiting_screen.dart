import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../presentation/history_controller.dart';

class PaymentWaitingScreen extends ConsumerStatefulWidget {
  // REVISI: Mengubah tipe menjadi dynamic agar bisa menerima TransactionItem dari CheckoutController
  final dynamic order; 
  const PaymentWaitingScreen({super.key, required this.order});

  @override
  ConsumerState<PaymentWaitingScreen> createState() => _PaymentWaitingScreenState();
}

class _PaymentWaitingScreenState extends ConsumerState<PaymentWaitingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _showSuccessOverlay = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

 
void _handleConfirmPayment() {
  // Ambil ID secara hati-hati
  final int? orderId = widget.order.id; 

  if (orderId != null) {
    ref.read(historyControllerProvider.notifier).updateStatus(orderId, 'packed');
    
    setState(() => _showSuccessOverlay = true);
    _animController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/transactions');
    });
  } else {
    print("❌ ERROR: Order ID tidak ditemukan!");
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C5098), Color(0xFF0E1A32)],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const Icon(Icons.timer_outlined, color: Colors.orange, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            "Selesaikan Pembayaran Dalam",
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const Text(
                            "23:59:59",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 30),
                          
                          _buildInfoCard(),
                          const SizedBox(height: 16),
                          // Mengakses field virtualAccount dari objek dynamic secara aman
                          _buildVACard(widget.order.virtualAccount?.toString() ?? "8801234567890123"),
                          
                          const SizedBox(height: 40),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_showSuccessOverlay) _buildSuccessOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/home'),
          ),
          const Text(
            "Pembayaran",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Total Tagihan", style: TextStyle(color: Colors.white70)),
          Text(
            // Mengakses totalAmount dari objek dynamic
            AppFormatters.formatRupiah(widget.order.totalAmount),
            style: const TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }



// Cari bagian build info card dan VA card, ganti dengan gaya ini:
Widget _buildVACard(String va) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Transfer ke Virtual Account", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(va, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: va));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("VA Berhasil disalin")));
              },
              child: const Text("SALIN", style: TextStyle(color: Color(0xFF2C5098), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const Divider(height: 30),
        const Text(
          "Gunakan ATM atau Mobile Banking untuk melakukan pembayaran sebelum waktu habis.",
          style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic),
        )
      ],
    ),
  );
}



  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _handleConfirmPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("KONFIRMASI PEMBAYARAN", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.go('/home'),
          child: const Text("Bayar Nanti", style: TextStyle(color: Colors.white60)),
        ),
      ],
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.all(40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                const Text(
                  "Pembayaran Berhasil",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  "Pesananmu sedang dikemas oleh penjual",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}