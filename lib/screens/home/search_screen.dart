import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/court_provider.dart';
import '../../widgets/court_card.dart'; // Pastikan widget ini sudah ada

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ambil data terbaru dan reset pencarian saat layar dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CourtProvider>(context, listen: false);
      provider.fetchCourts(); // Pastikan data terload
      provider.searchCourts(''); // Reset filter ke semua
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            // --- KOLOM PENCARIAN ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                  ],
                ),
                child: TextField(
                  controller: _ctrl,
                  autofocus: false,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    hintText: 'Cari nama lapangan atau alamat...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  // Menggunakan onChanged agar hasil muncul Real-time saat mengetik
                  onChanged: (value) {
                    context.read<CourtProvider>().searchCourts(value);
                  },
                ),
              ),
            ),

            // --- LIST HASIL ---
            Expanded(
              child: Consumer<CourtProvider>(
                builder: (context, cp, child) {
                  // 1. Cek Loading (Gunakan 'isLoading' bukan 'loading')
                  if (cp.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 2. Cek Kosong
                  if (cp.courts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 10),
                          Text(
                            "Tidak ditemukan lapangan",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  }

                  // 3. Tampilkan List
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: cp.courts.length,
                    itemBuilder: (ctx, i) => CourtCard(court: cp.courts[i]),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}