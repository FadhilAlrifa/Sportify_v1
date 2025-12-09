import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class AccountDetailScreen extends StatefulWidget {
  const AccountDetailScreen({super.key});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  // Controller untuk form
  final TextEditingController _nameController = TextEditingController(text: "User Sportify");
  final TextEditingController _phoneController = TextEditingController(text: "081234567890");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Akun", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Informasi Pribadi", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            _buildTextField("Nama Lengkap", _nameController, Ionicons.person_outline),
            const SizedBox(height: 15),
            _buildTextField("Nomor HP", _phoneController, Ionicons.call_outline, isNumber: true),
            const SizedBox(height: 15),
            
            // Email biasanya read-only kalau login pake Google/Auth
            _buildTextField("Email", TextEditingController(text: "user@sportify.com"), Ionicons.mail_outline, isReadOnly: true),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Tambahkan logika simpan ke Firebase di sini
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perubahan disimpan!")));
                },
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
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, bool isReadOnly = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: isReadOnly,
        fillColor: isReadOnly ? Colors.grey.shade100 : Colors.white,
      ),
    );
  }
}