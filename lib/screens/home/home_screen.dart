import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../../routes.dart';

import '../../widgets/navbar.dart'; 
import '../profile/profile_screen.dart';
import '../history/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; 
  final TextEditingController searchC = TextEditingController();

  final List<String> localImages = [
    "assets/futsal.png",
    "assets/badminton.png",
    "assets/basket.png",
    "assets/tennis.png",
    "assets/voli.png",
    "assets/minisoccer.png",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeContent(),                
      const HistoryScreen(),                // Index 1: History
      const ProfileScreen(),                // Index 2: Profil
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: screens[_selectedIndex],
      bottomNavigationBar: Navbar( 
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          // Header Gradient & Search
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 55, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00B380), Color(0xFF00DFA2)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchC,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Cari Lapangan / Venue...",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                      Icon(Ionicons.search, color: Colors.grey.shade700)
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text("Selamat Datang,",
                    style: TextStyle(color: Colors.white, fontSize: 17)),
                const Text("User Sportify",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Text("Kategori Olahraga",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blueGrey.shade800)),
          ),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _kategori("Futsal", Ionicons.football_outline, Colors.blue),
                _kategori("Badminton", Ionicons.tennisball_outline, Colors.pink),
                _kategori("Basket", Ionicons.basketball_outline, Colors.orange),
                _kategori("Voli", Ionicons.body_outline, Colors.green),
                _kategori("Tenis", Ionicons.tennisball, Colors.redAccent),
                _kategori("Lainnya", Ionicons.add, Colors.grey),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Text(
              "Lapangan Rating Tertinggi",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          
          // --- STREAM BUILDER UNTUK FIREBASE ---
          StreamBuilder<QuerySnapshot>(
            // Mengambil data dari koleksi 'venues' di Firestore
            stream: FirebaseFirestore.instance.collection('venues').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Terjadi kesalahan memuat data"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var docs = snapshot.data!.docs;

              if (searchC.text.isNotEmpty) {
                docs = docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name = (data['name'] ?? '').toString().toLowerCase();
                  return name.contains(searchC.text.toLowerCase());
                }).toList();
              }

              if (docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("Tidak ada lapangan ditemukan."),
                  ),
                );
              }

              return _venueGrid(docs);
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _kategori(String nama, IconData icon, Color warna) {
    return Container(
      margin: const EdgeInsets.only(right: 14),
      width: 72,
      child: Column(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: warna.withOpacity(.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: warna, size: 28),
          ),
          const SizedBox(height: 5),
          Text(nama,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _venueGrid(List<QueryDocumentSnapshot> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 185,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
        ),
        itemBuilder: (_, i) {
          final venueData = data[i].data() as Map<String, dynamic>;
          
          final venueId = data[i].id; 

          String localImage = localImages[i % localImages.length];

          String name = venueData['name'] ?? 'Tanpa Nama';
          String loc = venueData['address'] ?? 'Alamat tidak tersedia';
          double rating = (venueData['rating'] ?? 0.0).toDouble();

          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.courtDetail,
                arguments: {'id': venueId}, // Kirim ID dokumen Firebase
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GAMBAR (LOKAL)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: Image.asset(
                      localImage, // Tetap pakai aset lokal
                      height: 105,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NAMA (DARI FIREBASE)
                        Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5)),
                        Text(loc,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 11)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            // RATING (DARI FIREBASE)
                            Text("$rating • Tersedia",
                                style: const TextStyle(fontSize: 11))
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}