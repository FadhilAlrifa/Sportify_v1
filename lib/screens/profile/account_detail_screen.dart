import 'package:flutter/material.dart';
// import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

// Import halaman edit yang baru kita buat nanti
import 'edit_profile_screen.dart'; 

class AccountDetailScreen extends StatelessWidget {
  const AccountDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data user langsung dari Provider agar selalu update
    final user = Provider.of<AuthProvider>(context).user;
    // Jika ada data tambahan (seperti no hp) di provider, ambil juga:
    // final role = Provider.of<AuthProvider>(context).role; 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Informasi Akun", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // Tombol Edit di pojok kanan atas
          TextButton(
            onPressed: () {
              // Pindah ke halaman Edit Profil
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const EditProfileScreen())
              );
            },
            child: const Text("Ubah", style: TextStyle(color: Color(0xFF00B380), fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto Profil Besar
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  image: const DecorationImage(
                    image: AssetImage('assets/futsal.png'), // Ganti dengan user.photoURL jika ada
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Item Informasi (Menggunakan Widget kustom di bawah)
            _buildInfoTile("Nama Lengkap", user?.displayName ?? "Belum diatur"),
            _buildInfoTile("Email", user?.email ?? "-"),
            _buildInfoTile("Status", "User Aktif"), // Bisa diganti dengan variabel role
            
            // Contoh jika user login pakai Google biasanya no HP kosong di Auth
            _buildInfoTile("Nomor HP", user?.phoneNumber ?? "-"), 
          ],
        ),
      ),
    );
  }

  // Widget kecil untuk menampilkan Baris Informasi (Read Only)
  Widget _buildInfoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w600, 
              color: Colors.black87
            ),
          ),
        ],
      ),
    );
  }
}