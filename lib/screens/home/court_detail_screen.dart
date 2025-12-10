import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:intl/intl.dart'; // Untuk format Rupiah
import '../../routes.dart';

class CourtDetailScreen extends StatefulWidget {
  final String? courtId;

  const CourtDetailScreen({super.key, required this.courtId});

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  // Format mata uang Rupiah
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // Fungsi untuk mengambil detail lapangan dari Firestore
  Future<DocumentSnapshot> _getCourtDetails() async {
    if (widget.courtId == null) {
      throw Exception("ID Lapangan tidak ditemukan");
    }
    return await FirebaseFirestore.instance
        .collection('venues')
        .doc(widget.courtId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: FutureBuilder<DocumentSnapshot>(
        future: _getCourtDetails(),
        builder: (context, snapshot) {
          // 1. Cek Koneksi / Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Cek Error
          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }

          // 3. Cek Data Kosong
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Data lapangan tidak ditemukan"));
          }

          // 4. Ambil Data
          var data = snapshot.data!.data() as Map<String, dynamic>;

          // Data Default jika field kosong di Firebase
          String name = data['name'] ?? 'Nama Tidak Tersedia';
          String loc = data['address'] ?? 'Lokasi Tidak Tersedia';
          String description = data['description'] ?? 'Belum ada deskripsi untuk lapangan ini.';
          // int price = (data['price'] ?? 0).toInt();
          double rating = (data['rating'] ?? 0.0).toDouble();
          String imgUrl = data['imageUrl'] ?? ''; // Jika kosong, nanti pakai placeholder
          List<dynamic> facilities = data['facilities'] ?? []; 

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, name, imgUrl),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleAndRating(name, loc, rating),
                          const SizedBox(height: 15),
                          _buildDescription(description),
                          const SizedBox(height: 25),
                          // Hanya tampilkan fasilitas jika ada datanya
                          if (facilities.isNotEmpty) ...[
                            _buildFacilities(facilities),
                            const SizedBox(height: 25),
                          ],
                          _buildReviews(rating), // Bisa dikembangkan ambil ulasan real nanti
                          const SizedBox(height: 80), // Ruang untuk bottom bar
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      // Kita bungkus BottomBar dengan FutureBuilder juga atau pass data jika sudah ada
      // Agar lebih simpel, kita panggil BottomBar di dalam body atau gunakan StreamBuilder di root.
      // Tapi untuk struktur Scaffold, BottomBar di luar body.
      // Triknya: Ambil data sekali lagi atau buat variabel state jika ingin reaktif.
      // Sederhananya untuk detail statis, kita bisa taruh logic button di dalam FutureBuilder di atas 
      // (sebagai bagian dari Column/Stack), TAPI agar layout rapi (sticky bottom), kita gunakan StreamBuilder.
      
      // SOLUSI: Agar data harga muncul di BottomBar, kita pindahkan BottomBar ke dalam FutureBuilder 
      // (menggunakan Stack atau Column expanded), ATAU kita query ulang (cache firestore cepat kok).
      bottomNavigationBar: _buildBottomBarLoader(),
    );
  }

  // Widget khusus untuk meload data harga di bottom bar
  Widget _buildBottomBarLoader() {
    return FutureBuilder<DocumentSnapshot>(
      future: _getCourtDetails(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
        
        var data = snapshot.data!.data() as Map<String, dynamic>;
        int price = (data['price'] ?? 0).toInt();

        return _buildBottomBar(context, price);
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, String name, String imgUrl) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: const Color(0xFF00B47A),
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(50),
        ),
        child: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: imgUrl.isNotEmpty 
            ? Image.network(
                imgUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => Container(color: Colors.grey, child: const Icon(Icons.broken_image, size: 50, color: Colors.white)),
              )
            : Image.asset('assets/futsal.png', fit: BoxFit.cover), // Gambar default lokal
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            shadows: [Shadow(color: Colors.black45, blurRadius: 5)],
          ),
        ),
        titlePadding: const EdgeInsets.only(bottom: 16, left: 50, right: 20),
      ),
    );
  }

  Widget _buildTitleAndRating(String name, String loc, double rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade900,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Ionicons.location_outline, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                loc,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Ionicons.star, size: 16, color: Colors.amber.shade800),
                  const SizedBox(width: 4),
                  Text(
                    "$rating",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber.shade900),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text("(120 Ulasan)", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)), // Dummy ulasan
          ],
        )
      ],
    );
  }

  Widget _buildDescription(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Deskripsi",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildFacilities(List<dynamic> facilities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Fasilitas",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade800,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: facilities.map((facility) {
            return Chip(
              label: Text(facility.toString(),
                  style: const TextStyle(color: Color(0xFF00B47A), fontSize: 12)),
              backgroundColor: const Color(0xFF00B47A).withOpacity(0.1),
              side: const BorderSide(color: Color(0xFF00B47A), width: 0.5),
              padding: const EdgeInsets.all(0),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviews(double rating) {
    // Bagian ini masih dummy layout, bisa dikembangkan nanti
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Ulasan Pelanggan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade800,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("Lihat Semua", style: TextStyle(color: Color(0xFF00B47A))),
            ),
          ],
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Ionicons.person, color: Colors.white, size: 20),
          ),
          title: const Text("User Sportify", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: const Text("Tempatnya nyaman dan bersih!", style: TextStyle(fontSize: 13)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 14),
              Text(" $rating", style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, int price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Harga Sewa:",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  "${currencyFormatter.format(price)}/Jam",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00B47A),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  Routes.booking,
                  arguments: {
                    'id': widget.courtId,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B47A),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "BOOKING",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}