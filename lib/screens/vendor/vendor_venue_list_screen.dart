import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ionicons/ionicons.dart';
import 'package:intl/intl.dart'; // Pastikan package intl sudah ada di pubspec.yaml

import '../../providers/auth_provider.dart';
import '../../providers/court_provider.dart';
import '../../models/court.dart';
import '../../routes.dart';

class VendorVenueListScreen extends StatelessWidget {
  const VendorVenueListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil User ID untuk filtering
    final user = context.watch<AuthProvider>().user;
    final String? currentVendorId = user?.uid;

    if (currentVendorId == null) {
      return const Scaffold(
        body: Center(child: Text("Sesi habis. Silakan login ulang.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Background putih abu modern
      appBar: AppBar(
        title: const Text("Kelola Lapangan", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('venues')
            .where('vendorId', isEqualTo: currentVendorId)
            .snapshots(),
        builder: (context, snapshot) {
          // A. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // B. Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text("Terjadi kesalahan: ${snapshot.error}", textAlign: TextAlign.center),
              ),
            );
          }

          // C. Kosong
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context);
          }

          final docs = snapshot.data!.docs;

          // D. List Data
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final court = CourtModel.fromMap(data, docs[index].id);

              return _buildModernVendorCard(context, court);
            },
          );
        },
      ),
    );
  }

  // --- WIDGET: EMPTY STATE (Tampilan Kosong) ---
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Ionicons.storefront_outline, size: 60, color: Colors.green.shade300),
          ),
          const SizedBox(height: 20),
          const Text(
            "Belum Ada Lapangan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Anda belum mendaftarkan lapangan apapun.\nMulai tambahkan sekarang!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: KARTU LAPANGAN MODERN ---
  Widget _buildModernVendorCard(BuildContext context, CourtModel court) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Ke Detail
            Navigator.pushNamed(context, Routes.courtDetail, arguments: {'id': court.id});
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. GAMBAR (Kiri)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 90,
                    height: 90,
                    child: court.imageUrl.isNotEmpty
                        ? Image.network(
                            court.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                  ),
                ),
                
                const SizedBox(width: 14),

                // 2. INFO (Tengah)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori Badge (Label Biru Kecil)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          court.type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // Nama Lapangan
                      Text(
                        court.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 4),
                      
                      // Fasilitas count (Info tambahan)
                      if (court.facilities.isNotEmpty)
                        Text(
                          "${court.facilities.length} Fasilitas • ${court.availableTimes.length} Slot Jam",
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),

                      const SizedBox(height: 8),

                      // Harga
                      Text(
                        "${currencyFormat.format(court.price)}/Jam",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00B47A), // Hijau Sportify
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. TOMBOL DELETE (Kanan)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Ionicons.trash_outline, color: Colors.redAccent, size: 22),
                      tooltip: "Hapus",
                      onPressed: () => _showDeleteDialog(context, court),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- DIALOG KONFIRMASI HAPUS ---
  void _showDeleteDialog(BuildContext context, CourtModel court) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Lapangan?"),
        content: Text(
          "Anda yakin ingin menghapus '${court.name}'?\nTindakan ini tidak dapat dibatalkan.",
          style: const TextStyle(color: Colors.black54),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog dulu
              try {
                await Provider.of<CourtProvider>(context, listen: false).deleteVenue(court.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lapangan berhasil dihapus"), backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal menghapus: $e")),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}