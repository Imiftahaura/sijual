import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/utils/formatters.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../product/data/product_model.dart';
import '../data/order_model.dart';
import '../data/transaction_model.dart';
import 'checkout_controller.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? buyNowData;
  const CheckoutScreen({super.key, this.buyNowData});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  String _selectedCourier = 'Reguler (Standard)';
  int _shippingCost = 12000; 
  
  static const Color brandBlue = Color(0xFF2C5098);
  static const Color brandYellow = Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    // LOGIKA AUTO-FILL: Mengambil alamat dari data user yang login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authControllerProvider).value;
      if (user != null && user.address != null) {
        _addressController.text = user.address!;
      }
    });
  }

  void _processPayment(double subtotal, List<TransactionProductItem> items) async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alamat wajib diisi!")));
      return;
    }

    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    final request = OrderRequest(
      userId: user.id,
      totalAmount: subtotal + _shippingCost + 1000,
      shippingAddress: _addressController.text,
      shippingCourier: _selectedCourier,
      shippingCost: _shippingCost,
      paymentMethod: 'ONLINE_PAYMENT',
      items: items.map((e) => OrderItem(
        productId: int.parse(e.id),
        quantity: e.quantity,
        price: e.price,
        notes: _noteController.text,
      )).toList(),
    );

    // PERBAIKAN: Menambahkan parameter isBuyNow agar sinkron dengan CheckoutController
    await ref.read(checkoutControllerProvider.notifier).createOrder(
      request: request,
      items: items,
      isBuyNow: widget.buyNowData != null,
      onSuccess: (transaction) => context.go('/transactions/payment', extra: transaction),
      onError: (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    List<TransactionProductItem> displayItems = [];
    double subtotal = 0;

    if (widget.buyNowData != null) {
      final product = widget.buyNowData!['product'] as Product;
      final qty = widget.buyNowData!['quantity'] as int;
      displayItems = [TransactionProductItem(
        id: product.id.toString(),
        productName: product.name,
        quantity: qty,
        price: product.price.toDouble(),
        productImage: product.imageUrl,
      )];
      subtotal = product.price.toDouble() * qty;
    } else {
      // SINKRONISASI: Hanya mengambil item yang dipilih di keranjang
      final selectedCartItems = cartState.value?.items.where((e) => e.isSelected).toList() ?? [];
      displayItems = selectedCartItems.map((e) => TransactionProductItem(
        id: e.productId.toString(),
        productName: e.productName,
        quantity: e.quantity,
        price: e.price,
        productImage: e.image,
      )).toList();
      subtotal = displayItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: brandBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAddressSection(),
                  const SizedBox(height: 16),
                  _buildProductSection(displayItems),
                  const SizedBox(height: 16),
                  _buildShippingSection(),
                  const SizedBox(height: 16),
                  _buildPaymentSummary(subtotal),
                ],
              ),
            ),
          ),
          _buildBottomAction(subtotal, displayItems),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [Icon(Icons.location_on, color: brandYellow), SizedBox(width: 8), Text("Alamat Pengiriman", style: TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController, 
            decoration: const InputDecoration(
              hintText: "Masukkan Alamat...", 
              border: InputBorder.none, 
              filled: true, 
              fillColor: Color(0xFFF1F3F6)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection(List<TransactionProductItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Produk Pesanan", style: TextStyle(fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8), 
                  child: CachedNetworkImage(
                    imageUrl: item.productImage ?? '', 
                    width: 60, 
                    height: 60, 
                    fit: BoxFit.cover
                  )
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)), 
                      Text("${item.quantity} Barang", style: const TextStyle(color: Colors.grey, fontSize: 12))
                    ]
                  )
                ),
                Text(AppFormatters.formatRupiah(item.price), style: const TextStyle(fontWeight: FontWeight.bold, color: brandBlue)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildShippingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.local_shipping, color: brandBlue),
        title: Text(_selectedCourier, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  Widget _buildPaymentSummary(double subtotal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          _summaryRow("Subtotal Produk", AppFormatters.formatRupiah(subtotal)),
          _summaryRow("Ongkos Kirim", AppFormatters.formatRupiah(_shippingCost.toDouble())),
          _summaryRow("Biaya Layanan", AppFormatters.formatRupiah(1000)),
          const Divider(height: 20),
          _summaryRow("Total Tagihan", AppFormatters.formatRupiah(subtotal + _shippingCost + 1000), isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)), 
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: isTotal ? brandBlue : Colors.black, fontSize: isTotal ? 16 : 14))
        ]
      ),
    );
  }

  Widget _buildBottomAction(double subtotal, List<TransactionProductItem> items) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Text("Total Pembayaran", style: TextStyle(color: Colors.grey, fontSize: 12)), 
              Text(AppFormatters.formatRupiah(subtotal + _shippingCost + 1000), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: brandBlue))
            ]
          ),
          ElevatedButton(
            onPressed: () => _processPayment(subtotal, items),
            style: ElevatedButton.styleFrom(
              backgroundColor: brandBlue, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
            ),
            child: const Text("Buat Pesanan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}