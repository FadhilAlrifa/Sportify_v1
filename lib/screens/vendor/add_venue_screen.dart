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
    'Mini Soccer',
    'Padel'
  ];
  
  // State Fasilitas (Checkbox)
  final List<String> _allFacilities = [
    'WiFi', 'Toilet', 'Kantin', 'Parkir', 'Musholla', 'AC', 'Locker', 'Sewa Sepatu', 'Tribun'
  ];
  final List<String> _selectedFacilities = [];

  // --- STATE JAM OPERASIONAL (BARU) ---
  // List 24 Jam (00:00 - 23:00)
  final List<String> _allTimes = List.generate(24, (index) {
    return "${index.toString().padLeft(2, '0')}:00";
  });
  // Jam yang dipilih vendor
  final List<String> _selectedTimes = [];

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
              // --- SEKSI 1: INFO UTAMA ---
              const Text(
                "Informasi Utama", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              ),
              const SizedBox(height: 20),
              
              _buildInput(
                controller: _nameCtrl, 
                label: "Nama Venue", 
                icon: Icons.stadium, 
                type: TextInputType.text
              ),
              const SizedBox(height: 20),
              
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

              _buildInput(
                controller: _priceCtrl, 
                label: "Harga per Jam (Rp)", 
                icon: Icons.attach_money, 
                type: TextInputType.number
              ),
              const SizedBox(height: 20),

              _buildInput(
                controller: _addressCtrl, 
                label: "Alamat Lengkap", 
                icon: Icons.location_on, 
                type: TextInputType.text
              ),
              const SizedBox(height: 20),

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
              
              // --- SEKSI 2: DETAIL ---
              const Text(
                "Detail & Fasilitas", 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: _inputDecoration("Deskripsi Lapangan", Icons.description).copyWith(
                  alignLabelWithHint: true, 
                ),
                validator: (val) => val!.isEmpty ? "Deskripsi wajib diisi" : null,
              ),
              const SizedBox(height: 20),

              // PILIHAN JAM OPERASIONAL (BARU)
              const Text("Jam Operasional (Available Times):", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              const Text("Pilih jam-jam di mana lapangan bisa dibooking.", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allTimes.map((time) {
                  return FilterChip(
                    label: Text(time),
                    selected: _selectedTimes.contains(time),
                    selectedColor: const Color(0xFF00B47A).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF00B47A),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _selectedTimes.contains(time) 
                        ? const Color(0xFF00B47A) 
                        : Colors.black87
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedTimes.add(time);
                        } else {
                          _selectedTimes.remove(time);
                        }
                        // Sortir agar jam berurutan (08:00, 09:00, dst)
                        _selectedTimes.sort(); 
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // PILIHAN FASILITAS
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

              // TOMBOL SUBMIT
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

  // --- LOGIKA UPLOAD ---
  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap pilih kategori olahraga")));
      return;
    }
    // Validasi Jam
    if (_selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap pilih minimal satu jam operasional")));
      return;
    }

    setState(() => _isLoading = true);

    final userId = context.read<AuthProvider>().user?.uid;

    if (userId == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: User tidak terdeteksi.")));
      return;
    }

    Map<String, dynamic> newVenue = {
      'name': _nameCtrl.text.trim(),
      'type': _selectedType,
      'price': int.tryParse(_priceCtrl.text) ?? 0,
      'address': _addressCtrl.text.trim(),
      'imageUrl': _imageCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'facilities': _selectedFacilities,
      'availableTimes': _selectedTimes, // <--- DATA JAM DISIMPAN DI SINI
      'rating': 0.0,
      'createdAt': DateTime.now().toIso8601String(),
      'vendorId': userId,
    };

    final error = await context.read<CourtProvider>().addVenue(newVenue);

    if (mounted) setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lapangan Berhasil Ditambahkan!"), backgroundColor: Colors.green));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }

  // --- HELPER WIDGETS ---
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00B47A), width: 2)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String label, required IconData icon, required TextInputType type}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: _inputDecoration(label, icon),
      validator: (value) => value!.isEmpty ? "$label tidak boleh kosong" : null,
    );
  }
}