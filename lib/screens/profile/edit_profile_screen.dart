import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Kita sembunyikan AuthProvider milik Firebase agar tidak bentrok dengan milik kita
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    // Ambil data user saat ini untuk mengisi form otomatis
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    
    _nameController = TextEditingController(text: user?.displayName ?? "");
    _emailController = TextEditingController(text: user?.email ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // --- LOGIKA SIMPAN PERUBAHAN ---
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Tampilkan Loading
        showDialog(
          context: context, 
          barrierDismissible: false,
          builder: (c) => const Center(child: CircularProgressIndicator())
        );

        // Update Nama di Firebase Auth
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updateDisplayName(_nameController.text.trim());
          
          // Refresh Provider agar UI di halaman sebelumnya berubah
          // Kita bisa memanggil reload user, atau notifyListeners manual jika ada fungsi refresh
          await user.reload(); 
          // Opsional: Panggil fungsi di provider jika kamu menyimpannya di Firestore juga
        }

        // Tutup Loading
        if (mounted) Navigator.pop(context); 
        
        // Kembali ke halaman detail
        if (mounted) Navigator.pop(context); 

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui!")),
        );

      } catch (e) {
        Navigator.pop(context); // Tutup loading jika error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal update: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Edit Nama
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Nama tidak boleh kosong";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Edit Email (Biasanya email tidak boleh diedit sembarangan, jadi kita buat ReadOnly atau Disabled)
              TextFormField(
                controller: _emailController,
                readOnly: true, // Email dikunci
                decoration: InputDecoration(
                  labelText: "Email (Tidak dapat diubah)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "*Untuk mengubah email, silakan hubungi Customer Service.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 40),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B380),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}