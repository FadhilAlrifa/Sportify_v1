import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportify/routes.dart';
import '../../providers/auth_provider.dart';

// Import halaman fitur vendor
import 'add_venue_screen.dart';
import 'vendor_venue_list_screen.dart';

class VendorHomeScreen extends StatelessWidget {
  const VendorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data user yang sedang login untuk menampilkan nama
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Background agak abu sedikit biar kontras
      appBar: AppBar(
        title: const Text("Dashboard Mitra"),
        backgroundColor: const Color(0xFF00B47A), // Hijau Sportify
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Keluar",
            onPressed: () {
              // Fungsi Logout
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- KARTU SAMBUTAN ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFFE0F2F1), // Hijau muda sekali
                    child: Icon(Icons.storefront, size: 40, color: Color(0xFF00B47A)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Halo, ${user?.displayName ?? 'Mitra'}!",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Selamat datang di panel kelola lapangan.\nApa yang ingin Anda lakukan hari ini?",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "Menu Utama",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // --- GRID MENU ---
            Row(
              children: [
                // 1. TOMBOL TAMBAH LAPANGAN
                Expanded(
                  child: _buildMenuCard(
                    context,
                    title: "Tambah Lapangan",
                    icon: Icons.add_business,
                    color: Colors.blue,
                    onTap: () {
                      // Navigasi ke halaman Tambah Lapangan
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddVenueScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                
                // 2. TOMBOL LIST DAFTAR SAYA
                Expanded(
                  child: _buildMenuCard(
                    context,
                    title: "Lihat Daftar Saya",
                    icon: Icons.list_alt,
                    color: Colors.orange,
                    onTap: () {
                      // Navigasi ke halaman List Milik Vendor
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VendorVenueListScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 3. TOMBOL VALIDASI BOOKING
            Container(
              margin: const EdgeInsets.only(top: 12),
              child: Material(
                color: const Color(0xFF00B47A),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.validation);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.verified_user,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Validasi Booking",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Setujui atau tolak booking pelanggan",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper: Kartu Menu Kotak (Untuk Grid)
  Widget _buildMenuCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper: Kartu Menu Lebar (Untuk Laporan)
  // Widget _buildWideCard(BuildContext context,
  //     {required String title,
  //     required String subtitle,
  //     required IconData icon,
  //     required Color color,
  //     required VoidCallback onTap}) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       padding: const EdgeInsets.all(20),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(16),
  //         boxShadow: [
  //           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
  //         ],
  //       ),
  //       child: Row(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(12),
  //             decoration: BoxDecoration(
  //               color: color.withOpacity(0.1),
  //               shape: BoxShape.circle,
  //             ),
  //             child: Icon(icon, color: color, size: 28),
  //           ),
  //           const SizedBox(width: 16),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  //                 Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
  //               ],
  //             ),
  //           ),
  //           const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}