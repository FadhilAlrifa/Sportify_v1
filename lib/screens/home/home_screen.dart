import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../../routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchC = TextEditingController();

  List<Map<String, String>> venue = [
    {
      "img": "assets/futsal.png",
      "name": "Arena Futsal Gowa",
      "loc": "Jl. Malino Raya No.21"
    },
    {
      "img": "assets/badminton.png",
      "name": "Badminton Center",
      "loc": "Jl. Hertasning Baru No.17"
    },
    {
      "img": "assets/basket.png",
      "name": "Basketball Court",
      "loc": "Jl. Poros Pallangga No.42"
    },
    {
      "img": "assets/tennis.png",
      "name": "Tennis Arena",
      "loc": "Jl. Syekh Yusuf No.88"
    },
    {
      "img": "assets/voli.png",
      "name": "Voli Indoor Arena",
      "loc": "Jl. Tamalanrea Indah No.12"
    },
    {
      "img": "assets/minisoccer.png",
      "name": "Mini Soccer Field",
      "loc": "Jl. Metro Tanjung Bunga No.3"
    },
  ];

  List<Map<String, String>> get filteredVenue {
    if (searchC.text.isEmpty) return venue;
    return venue
        .where((v) =>
            v["name"]!.toLowerCase().contains(searchC.text.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 55, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00B380),
                  Color(0xFF00DFA2),
                ],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
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
              Text("Selamat Datang,",
                  style: TextStyle(color: Colors.white, fontSize: 17)),
              Text("User Sportify",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ]),
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
                _kategori(
                    "Badminton", Ionicons.tennisball_outline, Colors.pink),
                _kategori("Basket", Ionicons.basketball_outline, Colors.orange),
                _kategori("Voli", Ionicons.body_outline, Colors.green),
                _kategori("Tenis", Ionicons.tennisball, Colors.redAccent),
                _kategori("Lainnya", Ionicons.add, Colors.grey),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10), // Bawah 0
            child: Text(
              "Lapangan Rating Tertinggi",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          _venueGrid(filteredVenue),
          const SizedBox(height: 0),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF00B47A),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Ionicons.home_outline), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Ionicons.chatbubble_ellipses_outline), label: "Chat"),
          BottomNavigationBarItem(
              icon: Icon(Ionicons.receipt_outline), label: "Riwayat"),
          BottomNavigationBarItem(
              icon: Icon(Ionicons.person_outline), label: "Profil"),
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

  Widget _venueGrid(List<Map<String, String>> data) {
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
          final venueItem = data[i];
          return GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  Routes.courtDetail,
                  arguments: {
                    'id': venueItem["name"],
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18)),
                        child: Image.asset(data[i]["img"]!,
                            height: 105,
                            width: double.infinity,
                            fit: BoxFit.cover),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(9),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data[i]["name"]!,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5)),
                              Text(data[i]["loc"]!,
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 11)),
                              const SizedBox(height: 4),
                              Row(
                                children: const [
                                  Icon(Icons.star,
                                      size: 14, color: Colors.amber),
                                  SizedBox(width: 4),
                                  Text("4.9 • 200+ Booking",
                                      style: TextStyle(fontSize: 11))
                                ],
                              )
                            ]),
                      )
                    ]),
              ));
        },
      ),
    );
  }
}
