import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/transaction_model.dart';
import '../../../core/utils/formatters.dart';
import 'history_controller.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  // Tambahkan parameter untuk menerima status awal
  final String? initialStatus;
  
  const TransactionHistoryScreen({super.key, this.initialStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(historyControllerProvider);
    final primaryColor = Theme.of(context).primaryColor;

    // Logika menentukan index TabBar berdasarkan status yang dikirim dari AccountScreen
    int initialIndex = 0;
    if (initialStatus != null) {
      switch (initialStatus!.toLowerCase()) {
        case 'pending':
          initialIndex = 0;
          break;
        case 'packed':
          initialIndex = 1;
          break;
        case 'shipping':
          initialIndex = 2;
          break;
        case 'delivered':
          initialIndex = 3;
          break;
        default:
          initialIndex = 0;
      }
    }

    return DefaultTabController(
      length: 4,
      initialIndex: initialIndex, // Mengatur tab aktif otomatis saat pertama kali dibuka
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          title: const Text("Pesanan Saya",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.black54,
            indicatorColor: primaryColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: "Menunggu"),
              Tab(text: "Dikemas"),
              Tab(text: "Dikirim"),
              Tab(text: "Selesai"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTransactionList(context, ref, transactions, 'pending'),
            _buildTransactionList(context, ref, transactions, 'packed'),
            _buildTransactionList(context, ref, transactions, 'shipping'),
            _buildTransactionList(context, ref, transactions, 'delivered'),
          ],
        ),
      ),
    );
  }

  // DIALOG KONFIRMASI PEMBATALAN
  void _showCancelDialog(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Batalkan Pesanan?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin membatalkan pesanan ini? Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Kembali", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog
              try {
                await ref.read(historyControllerProvider.notifier).cancelTransaction(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pesanan berhasil dibatalkan"), behavior: SnackBarBehavior.floating),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal membatalkan: $e"), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, WidgetRef ref, List<TransactionItem> list, String status) {
    // Filter list berdasarkan status (case-insensitive)
    final filteredList = list.where((tx) => tx.status.toLowerCase().trim() == status.toLowerCase()).toList();

    if (filteredList.isEmpty) {
      return const Center(child: Text("Tidak ada pesanan"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: filteredList.length,
      itemBuilder: (context, index) => _buildTransactionCard(context, ref, filteredList[index]),
    );
  }

  Widget _buildTransactionCard(BuildContext context, WidgetRef ref, TransactionItem tx) {
    final status = tx.status.toLowerCase();
    final firstItem = (tx.items != null && tx.items!.isNotEmpty) ? tx.items!.first : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        // Gunakan path absolut ke detail agar tidak error di ShellRoute
        onTap: () => context.push('/account/transaction-detail/${tx.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // HEADER: ID & STATUS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(tx.invoiceNumber, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  _buildStatusBadge(tx),
                ],
              ),
              const SizedBox(height: 12),

              // BODY: GAMBAR & INFO PRODUK
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLargeProductImage(firstItem?.productImage),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          firstItem?.productName ?? "Produk",
                          maxLines: 2,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${firstItem?.quantity ?? 0} Barang",
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        Text(
                          AppFormatters.formatRupiah(firstItem?.price ?? 0),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // FOOTER: RINGKASAN TOTAL
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Total Pesanan (${tx.itemCount} Produk):", style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  Text(
                    AppFormatters.formatRupiah(tx.totalAmount),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),

              // TOMBOL AKSI: BAYAR & BATALKAN (Hanya muncul jika status pending)
              if (status == 'pending') ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: () => _showCancelDialog(context, ref, tx.id),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text("Batalkan", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () => context.push('/transactions/payment', extra: tx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: const Text("Bayar Sekarang", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TransactionItem tx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tx.status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tx.status.label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: tx.status.color),
      ),
    );
  }

  Widget _buildLargeProductImage(String? url) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: (url != null && url.isNotEmpty)
            ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))
            : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
      ),
    );
  }
}