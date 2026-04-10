import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../data/transaction_model.dart'; // Pastikan path ini benar
import 'transaction_detail_controller.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idInt = int.tryParse(transactionId) ?? 0;
    final detailAsync = ref.watch(transactionDetailProvider(idInt));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          "Detail Transaksi",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildErrorState(ref, idInt, err.toString()),
        data: (item) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 1. Status Section (Header) dengan Extension .label & .color
                      _buildHeaderStatus(item),

                      const SizedBox(height: 8),

                      // 2. Info Invoice & Pengiriman
                      _buildInvoiceInfo(item),

                      const SizedBox(height: 8),

                      // 3. Produk Section
                      _buildProductList(context, item),

                      const SizedBox(height: 8),

                      // 4. Ringkasan Pembayaran
                      _buildPaymentSummary(context, item),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              
              // 5. Bottom Action Button: Hanya muncul jika status 'pending'
              // Menggunakan toLowerCase() agar aman dari perbedaan huruf kapital
              if (item.status.toLowerCase() == 'pending')
                _buildBottomAction(context, item),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderStatus(TransactionItem item) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          // Menggunakan extension .color dari String status
          Icon(Icons.receipt_long_rounded, size: 40, color: item.status.color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.status.label, // Menggunakan extension .label
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: item.status.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Dipesan pada ${item.createdAt}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceInfo(TransactionItem item) {
    return _buildCardSection(
      child: Column(
        children: [
          _buildInfoRow("No. Invoice", item.invoiceNumber, isCopyable: true),
          const Divider(),
          _buildInfoRow("Metode Pembayaran", "Virtual Account / Manual"),
          if (item.trackingNumber != null) ...[
            const Divider(),
            _buildInfoRow("No. Resi", item.trackingNumber!),
          ]
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context, TransactionItem item) {
    return _buildCardSection(
      title: "Daftar Produk",
      child: Column(
        children: [
          if (item.items != null)
            ...item.items!.map((product) => Column(
              children: [
                InkWell(
                  onTap: () => context.push('/product/${product.id}'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductImage(product.productImage),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${product.quantity} x ${AppFormatters.formatRupiah(product.price)}",
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          AppFormatters.formatRupiah(product.price * product.quantity),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                if (item.items!.last != product) const Divider(),
              ],
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context, TransactionItem item) {
    return _buildCardSection(
      title: "Ringkasan Pembayaran",
      child: Column(
        children: [
          _buildSummaryRow("Total Harga", AppFormatters.formatRupiah(item.totalAmount)),
          _buildSummaryRow("Biaya Layanan", "Rp 0"),
          const Divider(height: 20),
          _buildSummaryRow(
            "Total Belanja", 
            AppFormatters.formatRupiah(item.totalAmount),
            isBold: true,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, TransactionItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              // Menuju konfirmasi pembayaran sesuai permintaan
              context.push('/payment_waiting_screen/${item.id}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              "Konfirmasi Pembayaran",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  // UI Helpers (Card, Row, Image, etc)
  Widget _buildCardSection({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isCopyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value, 
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)
                  ),
                ),
                if (isCopyable) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.copy, size: 14, color: Colors.blue),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? url) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: (url != null && url.isNotEmpty)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url, 
                fit: BoxFit.cover, 
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)
              ),
            )
          : const Icon(Icons.shopping_bag, color: Colors.grey),
    );
  }

  Widget _buildErrorState(WidgetRef ref, int id, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text("Gagal memuat: $error"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(transactionDetailProvider(id)),
            child: const Text("Coba Lagi"),
          )
        ],
      ),
    );
  }
}