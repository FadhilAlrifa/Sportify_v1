import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ionicons/ionicons.dart';
import '../../providers/auth_provider.dart';
import '../../providers/court_provider.dart';
import '../../models/court.dart';
import '../../routes.dart';

class VendorVenueListScreen extends StatelessWidget {
  const VendorVenueListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil ID User Vendor saat ini
    final String? currentVendorId = context.read<AuthProvider>().user?.uid;

    if (currentVendorId == null) {
      return const Scaffold(body: Center(child: Text("Error: User tidak ditemukan")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Lapangan Saya"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<QuerySnapshot>(
        // 2. QUERY: Ambil data 'venues' dimana 'vendorId' == Saya
        stream: FirebaseFirestore.instance
            .collection('venues')
            .where('vendorId', isEqualTo: currentVendorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.store_mall_directory_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Belum ada lapangan yang didaftarkan.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              // Ubah data firebase jadi model
              final data = docs[index].data() as Map<String, dynamic>;
              final court = CourtModel.fromMap(data, docs[index].id);

              return _buildVendorCard(context, court);
            },
          );
        },
      ),
    );
  }

  // Widget Kartu Khusus Vendor (Ada tombol Hapus)
  Widget _buildVendorCard(BuildContext context, CourtModel court) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: court.imageUrl.isNotEmpty
              ? Image.network(court.imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.broken_image)))
              : Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.image)),
        ),
        title: Text(court.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${court.type} • Rp ${court.price}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tombol Lihat Detail
            IconButton(
              icon: const Icon(Ionicons.eye_outline, color: Colors.blue),
              onPressed: () {
                Navigator.pushNamed(context, Routes.courtDetail, arguments: {'id': court.id});
              },
            ),
            // Tombol Hapus
            IconButton(
              icon: const Icon(Ionicons.trash_outline, color: Colors.red),
              onPressed: () => _confirmDelete(context, court.id, court.name),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Lapangan?"),
        content: Text("Anda yakin ingin menghapus '$name'? Data tidak bisa dikembalikan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog
              await Provider.of<CourtProvider>(context, listen: false).deleteVenue(docId);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lapangan dihapus")));
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}