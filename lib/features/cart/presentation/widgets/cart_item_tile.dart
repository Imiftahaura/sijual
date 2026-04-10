import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/cart_model.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final Function(int) onUpdateQty;
  final VoidCallback onRemove;
  final Function(bool?) onToggle;
  final bool isReadOnly;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onUpdateQty,
    required this.onRemove,
    required this.onToggle,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color(0xFF2C5098);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Checkbox Mungil
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: item.isSelected,
              activeColor: brandBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: isReadOnly ? null : onToggle,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 4),
          
          // Gambar Produk Ramping (64x64)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 64,
              height: 64,
              color: const Color(0xFFF6F7F9),
              child: item.image != null && item.image!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.image!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2, value: 20),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image_not_supported, 
                        color: Colors.grey, 
                        size: 20
                      ),
                    )
                  : const Icon(Icons.shopping_bag, color: Colors.grey, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          
          // Info & Controls
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nama Produk
                Text(
                  item.productName, 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 13, 
                    color: Color(0xFF1A1A1A)
                  ),
                ),
                const SizedBox(height: 2),
                
                // Harga
                Text(
                  AppFormatters.formatRupiah(item.price),
                  style: const TextStyle(
                    color: brandBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Qty & Delete Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Plus Minus Ramping
                    Container(
                      height: 26,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          _buildSmallQtyBtn(
                            icon: Icons.remove, 
                            onTap: isReadOnly || item.quantity <= 1 
                                ? null 
                                : () => onUpdateQty(item.quantity - 1)
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "${item.quantity}", 
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
                            ),
                          ),
                          _buildSmallQtyBtn(
                            icon: Icons.add, 
                            onTap: isReadOnly 
                                ? null 
                                : () => onUpdateQty(item.quantity + 1)
                          ),
                        ],
                      ),
                    ),
                    
                    // Tombol Hapus Kecil
                    if (!isReadOnly)
                      GestureDetector(
                        onTap: onRemove,
                        child: const Icon(
                          Icons.delete_outline_rounded, 
                          color: Colors.grey, 
                          size: 20
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method untuk tombol Qty agar kode tetap bersih
  Widget _buildSmallQtyBtn({required IconData icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 28,
        alignment: Alignment.center,
        child: Icon(
          icon, 
          size: 14, 
          color: onTap == null ? Colors.grey[300] : Colors.black87
        ),
      ),
    );
  }
}