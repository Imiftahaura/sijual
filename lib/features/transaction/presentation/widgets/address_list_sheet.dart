// lib/features/transaction/presentation/widgets/address_list_sheet.dart

import 'package:flutter/material.dart';

class AddressListSheet extends StatelessWidget {
  final String? currentAddress;
  final Function(String) onAddressSelected;

  const AddressListSheet({
    super.key, 
    this.currentAddress, 
    required this.onAddressSelected
  });

  @override
  Widget build(BuildContext context) {
    // Simulasi daftar alamat (Idealnya ini diambil dari API/Database)
    final List<Map<String, String>> savedAddresses = [
      {
        'label': 'Rumah Utama',
        'address': 'Jl. Raya Pajajaran No. 123, Bogor Tengah, Kota Bogor, Jawa Barat 16128',
      },
      {
        'label': 'Kantor',
        'address': 'Gedung IBIK, Jl. Rangga Gading No.01, Gudang, Kota Bogor',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text("Pilih Alamat Pengiriman", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          ...savedAddresses.map((item) => RadioListTile<String>(
            value: item['address']!,
            groupValue: currentAddress,
            title: Text(item['label']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['address']!),
            activeColor: Colors.orange[800],
            onChanged: (val) {
              if (val != null) {
                onAddressSelected(val);
                Navigator.pop(context);
              }
            },
          )),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add_location_alt_outlined),
            title: const Text("Tambah Alamat Baru"),
            onTap: () {
              // Logika tambah alamat baru
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}