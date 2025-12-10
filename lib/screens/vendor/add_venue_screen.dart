import 'package:flutter/material.dart';
// import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

// Import Provider
import '../../providers/auth_provider.dart';
import '../../providers/court_provider.dart';

class AddVenueScreen extends StatefulWidget {
  const AddVenueScreen({super.key});

  @override
  State<AddVenueScreen> createState() => _AddVenueScreenState();
}

class _AddVenueScreenState extends State<AddVenueScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controller Input Text
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

  // State Dropdown Kategori
  String? _selectedType;
  final List<String> _types = [
    'Futsal', 
    'Badminton', 
    'Basket', 
    'Voli', 
    'Tenis', 
    'Mini Soccer'
  ];
  
  // State Fasilitas (Checkbox)
  final List<String> _allFacilities = [
    'WiFi', 
    'Toilet', 
    'Kantin', 
    'Parkir', 
    'Musholla', 
    'AC', 
    'Locker', 
    'Sewa Sepatu',
    'Tribun'
  ];
  
  // List untuk menyimpan fasilitas yang dipilih
  final List<String> _selectedFacilities = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Lapangan Baru"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Informasi Utama", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              ),
              const SizedBox(height: 20),
              
              // 1. Nama Lapangan
              _buildInput(
                controller: _nameCtrl, 
                label: "Nama Venue", 
                icon: Icons.stadium, 
                type: TextInputType.text
              ),
              const SizedBox(height: 20),
              
              // 2. Kategori (Dropdown)
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: _inputDecoration("Kategori Olahraga", Icons.category),
                items: _types.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) => setState(() => _selectedType = val),
                validator: (val) => val == null ? "Pilih kategori" : null,
              ),
              const SizedBox(height: 20),

              // 3. Harga
              _buildInput(
                controller: _priceCtrl, 
                label: "Harga per Jam (Rp)", 
                icon: Icons.attach_money, 
                type: TextInputType.number
              ),
              const SizedBox(height: 20),

              // 4. Alamat
              _buildInput(
                controller: _addressCtrl, 
                label: "Alamat Lengkap", 
                icon: Icons.location_on, 
                type: TextInputType.text
              ),
              const SizedBox(height: 20),

              // 5. URL Gambar
              _buildInput(
                controller: _imageCtrl, 
                label: "Link URL Gambar", 
                icon: Icons.image, 
                type: TextInputType.url
              ),
              const SizedBox(height: 5),
              const Text(
                "*Tips: Salin 'Image Address' dari Google Images", 
                style: TextStyle(color: Colors.grey, fontSize: 12)
              ),
              
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
              
              const Text(
                "Detail & Fasilitas", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              ),
              const SizedBox(height: 20),

              // 6. Deskripsi
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: _inputDecoration("Deskripsi Lapangan", Icons.description).copyWith(
                  alignLabelWithHint: true, // Agar label ada di pojok kiri atas
                ),
                validator: (val) => val!.isEmpty ? "Deskripsi wajib diisi" : null,
              ),
              const SizedBox(height: 20),

              // 7. Fasilitas (Wrap & FilterChip)
              const Text("Fasilitas Tersedia:", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allFacilities.map((facility) {
                  return FilterChip(
                    label: Text(facility),
                    selected: _selectedFacilities.contains(facility),
                    selectedColor: const Color(0xFF00B47A).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF00B47A),
                    labelStyle: TextStyle(
                      color: _selectedFacilities.contains(facility) 
                        ? const Color(0xFF00B47A) 
                        : Colors.black87
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedFacilities.add(facility);
                        } else {
                          _selectedFacilities.remove(facility);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // 8. Tombol Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B47A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      ) 
                    : const Text(
                        "UPLOAD LAPANGAN", 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- LOGIKA UPLOAD KE FIREBASE ---
  Future<void> _submitData() async {
    // 1. Validasi Form
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap pilih kategori olahraga")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Ambil ID Vendor (User yang sedang login)
    // Ini PENTING agar lapangan terhubung dengan akun vendor
    final userId = context.read<AuthProvider>().user?.uid;

    if (userId == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: User tidak terdeteksi. Silakan login ulang.")),
      );
      return;
    }

    // 3. Siapkan Data
    Map<String, dynamic> newVenue = {
      'name': _nameCtrl.text.trim(),
      'type': _selectedType, // Penting untuk filter kategori di Home
      'price': int.tryParse(_priceCtrl.text) ?? 0, // Pastikan jadi angka
      'address': _addressCtrl.text.trim(),
      'imageUrl': _imageCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'facilities': _selectedFacilities,
      'rating': 0.0, // Default rating
      'createdAt': DateTime.now().toIso8601String(),
      'vendorId': userId, // <--- Field Kunci untuk fitur "Daftar Lapangan Saya"
    };

    // 4. Kirim via CourtProvider
    final error = await context.read<CourtProvider>().addVenue(newVenue);

    if (mounted) setState(() => _isLoading = false);

    // 5. Cek Hasil
    if (error == null) {
      // Sukses
      if (mounted) {
        Navigator.pop(context); // Tutup halaman
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lapangan Berhasil Ditambahkan!"), 
            backgroundColor: Colors.green
          ),
        );
      }
    } else {
      // Gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- HELPER WIDGETS (Untuk Desain) ---
  
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
        borderSide: const BorderSide(color: Color(0xFF00B47A), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildInput({
    required TextEditingController controller, 
    required String label, 
    required IconData icon, 
    required TextInputType type
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: _inputDecoration(label, icon),
      validator: (value) => value!.isEmpty ? "$label tidak boleh kosong" : null,
    );
  }
}