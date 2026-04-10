import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF2C5098);
    const Color brandYellow = Color(0xFFFFD700);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: brandYellow.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IMAGE SECTION (DIPERBESAR)
            Expanded(
              flex: 14, // Proporsi gambar lebih besar dari teks
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover, // Gambar tetap rapi landscape/portrait
                  width: double.infinity,
                  errorWidget: (context, url, error) => Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
                ),
              ),
            ),
            
            // 2. INFO SECTION
            Expanded(
              flex: 8,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF222222), height: 1.2),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppFormatters.formatRupiah(product.price),
                          style: const TextStyle(color: brandBlue, fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        // LOKASI DENGAN IKON KUNING KUNYIT
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 12, color: brandYellow),
                            const SizedBox(width: 4),
                            const Expanded(
                              child: Text(
                                "Lapas Kelas 1 Cipinang",
                                style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}