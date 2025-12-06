import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller Text Input
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Buat Akun Baru",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Gabung komunitas olahraga terbesar sekarang",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 40),

                // --- INPUT NAMA ---
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _inputDecoration("Nama Lengkap", Icons.person_outline),
                  validator: (value) =>
                      value!.isEmpty ? "Nama wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                // --- INPUT EMAIL ---
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("Email", Icons.email_outlined),
                  validator: (value) =>
                      !value!.contains('@') ? "Email tidak valid" : null,
                ),
                const SizedBox(height: 16),

                // --- INPUT PASSWORD ---
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: _inputDecoration("Password", Icons.lock_outline),
                  validator: (value) =>
                      value!.length < 6 ? "Password minimal 6 karakter" : null,
                ),
                const SizedBox(height: 32),

                // --- TOMBOL REGISTER ---
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "DAFTAR SEKARANG",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  "Dengan mendaftar, Anda menyetujui Syarat & Ketentuan kami.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Gunakan dekorasi yang sama agar konsisten
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  // Logika Register
  Future<void> _handleRegister() async {
    // 1. Validasi Form
    if (!_formKey.currentState!.validate()) return;

    // 2. Mulai Loading
    setState(() => _isLoading = true);

    // 3. Panggil Provider (Perhatikan Koma nya)
    final error = await context.read<AuthProvider>().register(
      _nameCtrl.text.trim(),   // Nama
      _emailCtrl.text.trim(),  // Email
      _passCtrl.text.trim(),   // Password
    );

    // 4. Stop Loading
    if (mounted) setState(() => _isLoading = false);

    // 5. Cek Hasil
    if (error == null) {
      // SUKSES
      if (mounted) {
        Navigator.pop(context); // Kembali ke Login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Akun berhasil dibuat! Silakan login."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // GAGAL
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}