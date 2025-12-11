import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class CategoryList extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onTap;

  const CategoryList({
    super.key,
    required this.selectedCategory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // Tambahkan opsi "Semua" atau "All"
          _kategoriItem("All", Ionicons.grid_outline, Colors.grey),
          
          // Pastikan nama ini SAMA PERSIS dengan field 'type' di Firebase Anda
          _kategoriItem("Futsal", Ionicons.football_outline, Colors.blue),
          _kategoriItem("Badminton", Ionicons.tennisball_outline, Colors.pink),
          _kategoriItem("Basket", Ionicons.basketball_outline, Colors.orange),
          _kategoriItem("Padel", Ionicons.tennisball, const Color.fromARGB(255, 255, 82, 255)),
          _kategoriItem("Voli", Ionicons.body_outline, Colors.green),
          _kategoriItem("Tenis", Ionicons.tennisball, Colors.redAccent),
          _kategoriItem("Mini Soccer", Ionicons.earth, Colors.teal), // Sesuaikan ikon
        ],
      ),
    );
  }

  Widget _kategoriItem(String nama, IconData icon, Color warna) {
    // Cek apakah item ini sedang dipilih
    final bool isSelected = selectedCategory == nama;

    return GestureDetector(
      onTap: () => onTap(nama), // Kirim nama kategori saat diklik
      child: Container(
        margin: const EdgeInsets.only(right: 14),
        width: 72,
        child: Column(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                // Jika dipilih: Warna asli. Jika tidak: Abu-abu transparan/putih
                color: isSelected ? warna : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? warna : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: isSelected 
                  ? [BoxShadow(color: warna.withOpacity(0.4), blurRadius: 5, offset: const Offset(0, 2))]
                  : [],
              ),
              // Jika dipilih: Ikon putih. Jika tidak: Warna asli ikon
              child: Icon(icon, color: isSelected ? Colors.white : warna, size: 28),
            ),
            const SizedBox(height: 5),
            Text(
              nama == "All" ? "Semua" : nama, // Tampilkan "Semua" di UI, tapi logic tetap "All"
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11, 
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}