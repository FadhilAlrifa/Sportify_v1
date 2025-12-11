import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
// PENTING: Gunakan 'hide AuthProvider' agar tidak bentrok dengan Provider buatanmu
// import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart'; 

// Import Provider buatanmu
import '../../providers/auth_provider.dart'; 

// Import Halaman Detail
import 'account_detail_screen.dart';
import 'payment_method_screen.dart';
import 'notification_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- LOGIKA LOGOUT (SUDAH BENAR) ---
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Keluar"),
        content: const Text("Yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Batal")
          ),
          TextButton(
            onPressed: () async {
              // 1. Tutup Dialog
              Navigator.pop(context);

              // 2. Panggil Provider Logout
              // Ini akan otomatis me-refresh main.dart ke halaman Login
              await Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- HELPER NAVIGASI ---
  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    // Ambil user dari Provider
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profil Saya", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, 
        // BAGIAN ACTIONS (ICON SETTINGS) SUDAH SAYA HAPUS DI SINI
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Foto Profil
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: AssetImage('assets/futsal.png'), 
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: Colors.grey.shade200, width: 4),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00B380),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Ionicons.camera, color: Colors.white, size: 20),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Nama & Email
            Text(
              user?.displayName ?? "User Sportify",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? "user@sportify.com",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),
            
            // Tombol Edit
            SizedBox(
              width: 200,
              height: 45,
              child: ElevatedButton(
                // Hapus const agar tidak error
                onPressed: () => _navigateTo(context, AccountDetailScreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B380),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Edit Profil", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),

            // --- MENU PILIHAN ---
            _buildProfileItem(
              icon: Ionicons.person_outline, 
              title: "Detail Akun",
              onTap: () => _navigateTo(context, AccountDetailScreen()),
            ),
            _buildProfileItem(
              icon: Ionicons.card_outline, 
              title: "Metode Pembayaran",
              onTap: () => _navigateTo(context, PaymentMethodScreen()),
            ),
            _buildProfileItem(
              icon: Ionicons.notifications_outline, 
              title: "Notifikasi",
              onTap: () => _navigateTo(context, NotificationScreen()),
            ),
            _buildProfileItem(
              icon: Ionicons.help_circle_outline, 
              title: "Bantuan & Support",
              onTap: () => _navigateTo(context, HelpSupportScreen()),
            ),
            
            const SizedBox(height: 20),
            
            // Tombol Keluar
            ListTile(
              onTap: () => _handleLogout(context),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Ionicons.log_out_outline, color: Colors.red),
              ),
              title: const Text("Keluar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Ionicons.chevron_forward, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}