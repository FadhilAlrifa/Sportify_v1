import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Metode Pembayaran", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildPaymentCard("Gopay", "0812****7890", "assets/gopay_logo.png", true), // Ganti aset dengan icon jika belum ada
          _buildPaymentCard("OVO", "0812****7890", "assets/ovo_logo.png", false),
          
          const SizedBox(height: 20),
          ListTile(
            onTap: () {},
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Ionicons.add, color: Color(0xFF00B380)),
            ),
            title: const Text("Tambah Metode Pembayaran"),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )
        ],
      ),
    );
  }

  Widget _buildPaymentCard(String name, String number, String assetPath, bool isConnected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isConnected ? Border.all(color: const Color(0xFF00B380), width: 1.5) : null,
      ),
      child: Row(
        children: [
          const Icon(Ionicons.card, size: 40, color: Colors.blueGrey), // Placeholder icon
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(number, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          if (isConnected)
            const Text("Terhubung", style: TextStyle(color: Color(0xFF00B380), fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}