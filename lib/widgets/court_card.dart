import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../models/court.dart'; // Pastikan path ini benar mengarah ke model Anda
import '../routes.dart'; // Pastikan path ini benar mengarah ke routes Anda

class CourtCard extends StatelessWidget {
  final CourtModel court;

  const CourtCard({super.key, required this.court});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke Detail saat kartu diklik
        Navigator.of(context).pushNamed(
          Routes.courtDetail,
          arguments: {'id': court.id},
        );
      },
      child: Container(
        // Margin agar ada jarak antar kartu
        margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN GAMBAR ---
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: court.imageUrl.isNotEmpty
                  ? Image.network(
                      court.imageUrl,
                      height: 150, // Tinggi gambar fix agar rapi
                      width: double.infinity,
                      fit: BoxFit.cover,
                      
                      // Loading Builder: Tampil saat gambar sedang diunduh
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      
                      // Error Builder: Tampil jika link gambar rusak
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, color: Colors.grey),
                              SizedBox(height: 4),
                              Text("Gagal memuat gambar", style: TextStyle(fontSize: 10, color: Colors.grey))
                            ],
                          ),
                        );
                      },
                    )
                  // Fallback: Tampil jika imageUrl kosong dari database
                  : Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
            ),

            // --- BAGIAN TEKS ---
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Lapangan
                  Text(
                    court.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  
                  // Alamat
                  const SizedBox(height: 4),
                  Text(
                    court.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Baris Bawah: Rating & Harga
                  Row(
                    children: [
                      // Rating
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        "${court.rating} • ${court.type}", // Menampilkan Rating & Tipe
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      
                      const Spacer(), // Dorong harga ke kanan
                      
                      // Harga
                      Text(
                        "Rp ${court.price}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00B47A), // Warna Hijau Sportify
                          fontSize: 14,
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}