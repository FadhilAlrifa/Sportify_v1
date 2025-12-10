import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes.dart';

import '../../widgets/navbar.dart'; 
import '../../widgets/category_list.dart'; // Import widget kategori

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

  // 1. VARIABLE STATE UNTUK KATEGORI
  // Default 'All' artinya menampilkan semua data
  String _selectedCategory = "All"; 

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 2. FUNGSI GANTI KATEGORI
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeContent(),                  
      const HistoryScreen(),               
      const ProfileScreen(),               
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
                const Text("Selamat Datang,", style: TextStyle(color: Colors.white, fontSize: 17)),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    // Ambil nama dari user yang sedang login
                    // Jika nama kosong/null, tampilkan "User Sportify" sebagai cadangan
                    String displayName = auth.user?.displayName ?? "User Sportify";
                    
                    return Text(
                      displayName, // <--- Variabel Nama Dinamis
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Biar tidak berantakan kalau nama panjang
                    );
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Text("Kategori Olahraga",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey.shade800)),
          ),
          
          // 3. PANGGIL CATEGORY LIST DENGAN PARAMETER
          CategoryList(
            selectedCategory: _selectedCategory,
            onTap: _onCategorySelected, // Kirim fungsi pengganti state
          ), 

          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Text(
              "Daftar Lapangan", // Judul saya ganti sedikit agar lebih umum
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          
          // Stream Builder
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('venues').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text("Error memuat data"));
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

              var docs = snapshot.data!.docs;

              // --- LOGIKA FILTERING GANDA (SEARCH + KATEGORI) ---
              
              // Filter 1: Berdasarkan Search Bar
              if (searchC.text.isNotEmpty) {
                docs = docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name = (data['name'] ?? '').toString().toLowerCase();
                  return name.contains(searchC.text.toLowerCase());
                }).toList();
              }

              // Filter 2: Berdasarkan Kategori yang Dipilih
              // Kita hanya filter jika kategori bukan "All"
              if (_selectedCategory != "All") {
                docs = docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String type = (data['type'] ?? '').toString(); // Pastikan field di firebase adalah 'type'
                  
                  // Bandingkan type di firebase dengan nama kategori
                  // Contoh: "Futsal" == "Futsal"
                  return type.toLowerCase() == _selectedCategory.toLowerCase();
                }).toList();
              }

              // Cek jika hasil kosong setelah difilter
              if (docs.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Ionicons.search_outline, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      Text(
                        "Tidak ada lapangan $_selectedCategory ditemukan.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
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

  // ... (Fungsi _venueGrid di bawah SAMA PERSIS dengan sebelumnya, tidak perlu diubah)
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
          
          String name = venueData['name'] ?? 'Tanpa Nama';
          String loc = venueData['address'] ?? 'Alamat tidak tersedia';
          double rating = (venueData['rating'] ?? 0.0).toDouble();
          String imageUrl = venueData['imageUrl'] ?? ''; 

          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.courtDetail,
                arguments: {'id': venueId}, 
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            height: 105,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              height: 105, color: Colors.grey[300], child: const Icon(Icons.broken_image, color: Colors.grey)
                            ),
                          )
                        : Container(height: 105, color: Colors.grey[300], child: const Icon(Icons.image, color: Colors.grey)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(9),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                        Text(loc, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text("$rating • Tersedia", style: const TextStyle(fontSize: 11))
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