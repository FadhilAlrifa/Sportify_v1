import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ionicons/ionicons.dart';
import 'package:intl/intl.dart'; // Tambahkan untuk format harga
import '../../routes.dart';

class VendorVenueListScreen extends StatelessWidget {
  const VendorVenueListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Lapangan"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<QuerySnapshot>(
        // Ambil semua data dari collection 'venues'
        stream: FirebaseFirestore.instance
            .collection('venues')
            .orderBy('name') // Urutkan berdasarkan nama
            .snapshots(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00B47A),
              ),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Jika tidak ada data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_soccer,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Belum ada lapangan tersedia",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tambahkan lapangan pertama Anda",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              // Ekstrak data dari Firebase
              final name = data['name'] ?? 'Tanpa Nama';
              final type = data['type'] ?? 'Umum';
              final address = data['address'] ?? 'Alamat tidak tersedia';
              final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
              final imageUrl = data['imageUrl'] ?? '';
              final price = (data['price'] as num?)?.toDouble() ?? 0.0;

              return _buildVenueCard(
                context: context,
                docId: docId,
                name: name,
                type: type,
                address: address,
                rating: rating,
                imageUrl: imageUrl,
                price: price,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman tambah lapangan
          Navigator.pushNamed(context, Routes.addVenue);
        },
        backgroundColor: const Color(0xFF00B47A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget untuk menampilkan card lapangan
  Widget _buildVenueCard({
    required BuildContext context,
    required String docId,
    required String name,
    required String type,
    required String address,
    required double rating,
    required String imageUrl,
    required double price,
  }) {
    final priceFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final formattedPrice = priceFormatter.format(price);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Lapangan
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 180,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Gagal memuat gambar',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tidak ada gambar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // Detail Lapangan
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama dan Type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        type.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Alamat
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        address,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Rating dan Harga
                Row(
                  children: [
                    // Rating
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Harga
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B47A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: const Color(0xFF00B47A).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.attach_money,
                            size: 14,
                            color: Color(0xFF00B47A),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedPrice,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00B47A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Tombol Aksi
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Navigasi ke detail lapangan
                          Navigator.pushNamed(
                            context,
                            Routes.courtDetail,
                            arguments: {'id': docId},
                          );
                        },
                        icon: const Icon(
                          Ionicons.eye_outline,
                          size: 18,
                        ),
                        label: const Text('Lihat Detail'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00B47A),
                          side: const BorderSide(color: Color(0xFF00B47A)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmDelete(context, docId, name),
                        icon: const Icon(
                          Ionicons.trash_outline,
                          size: 18,
                        ),
                        label: const Text('Hapus'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
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

  // Fungsi untuk mendapatkan warna berdasarkan tipe lapangan
  Color _getTypeColor(String type) {
    final typeLower = type.toLowerCase();

    if (typeLower.contains('futsal')) {
      return Colors.blue;
    } else if (typeLower.contains('badminton')) {
      return Colors.green;
    } else if (typeLower.contains('tennis')) {
      return Colors.orange;
    } else if (typeLower.contains('basket')) {
      return Colors.purple;
    } else if (typeLower.contains('voli')) {
      return Colors.red;
    } else if (typeLower.contains('sepak bola')) {
      return Colors.green.shade700;
    }

    return const Color(0xFF00B47A); // Default color
  }

  // Fungsi untuk konfirmasi hapus
  void _confirmDelete(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Hapus Lapangan?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Anda yakin ingin menghapus lapangan '$name'? Tindakan ini tidak dapat dibatalkan.",
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Batal",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog

              try {
                // Hapus dari Firebase
                await FirebaseFirestore.instance
                    .collection('venues')
                    .doc(docId)
                    .delete();

                // Tampilkan snackbar sukses
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Lapangan '$name' berhasil dihapus"),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                // Tampilkan snackbar error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Error: ${e.toString()}"),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
