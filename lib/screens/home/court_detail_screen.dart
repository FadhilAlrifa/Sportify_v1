import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../../routes.dart';

class CourtDetailScreen extends StatelessWidget {
  final String? courtId;

  final Map<String, dynamic> venueData = const {
    "img": "assets/futsal.png",
    "name": "Arena Futsal Gowa",
    "loc": "Jl. Malino Raya No.21",
    "rating": 4.9,
    "bookings": 235,
    "price": "Rp 150.000 / Jam",
    "description":
        "Arena Futsal Gowa adalah fasilitas olahraga modern yang menawarkan tiga lapangan futsal indoor berkualitas tinggi. Cocok untuk sesi latihan, turnamen, atau pertandingan persahabatan. Tersedia juga kafetaria dan ruang ganti yang bersih.",
    "facilities": const [
      "AC",
      "Ruang Ganti",
      "Toilet",
      "Kafetaria",
      "Area Parkir Luas"
    ],
    "reviews": 120,
  };

  const CourtDetailScreen({super.key, required this.courtId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleAndRating(),
                      const SizedBox(height: 15),
                      _buildDescription(),
                      const SizedBox(height: 25),
                      _buildFacilities(),
                      const SizedBox(height: 25),
                      _buildReviews(),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF00B47A),
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 10, top: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(50),
        ),
        child: IconButton(
          icon: const Icon(Ionicons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Image.asset(
          venueData["img"]!,
          fit: BoxFit.cover,
          errorBuilder: (c, o, s) =>
              Image.asset('assets/futsal.png', fit: BoxFit.cover),
        ),
        title: Text(
          venueData["name"]!,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        titlePadding: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      ),
    );
  }

  Widget _buildTitleAndRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          venueData["name"]!,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade900,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Ionicons.location_outline, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              venueData["loc"]!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const Spacer(),
            Icon(Ionicons.star, size: 18, color: Colors.amber.shade700),
            const SizedBox(width: 4),
            Text(
              "${venueData["rating"]} (${venueData["reviews"]} Ulasan)",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
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
          venueData["description"]!,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildFacilities() {
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
          children: (venueData["facilities"] as List<String>).map((facility) {
            return Chip(
              label: Text(facility,
                  style: const TextStyle(color: Color(0xFF00B47A))),
              backgroundColor: const Color(0xFF00B47A).withOpacity(0.1),
              side: const BorderSide(color: Color(0xFF00B47A), width: 0.5),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ulasan Pelanggan",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey.shade800,
          ),
        ),
        const SizedBox(height: 10),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Ionicons.person_outline, color: Colors.white),
          ),
          title: const Text("Pemain Hebat"),
          subtitle: const Text(
              "Tempatnya bersih dan lapangannya terawat dengan baik!"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.star, color: Colors.amber, size: 14),
              SizedBox(width: 4),
              Text("5.0"),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              "Lihat Semua Ulasan >",
              style: TextStyle(
                  color: Color(0xFF00B47A), fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Harga Mulai:",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                venueData["price"]!,
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
                  'id': courtId,
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
              "BOOKING SEKARANG",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}