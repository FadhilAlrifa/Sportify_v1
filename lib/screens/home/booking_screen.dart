import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportify/screens/payment/payment_bottom_sheet.dart';

class BookingScreen extends StatefulWidget {
  final dynamic courtId;

  const BookingScreen({super.key, required this.courtId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // State Variables
  DateTime? _selectedDate;
  String? _selectedTime;
  int _selectedDuration = 1;
  
  List<String> _availableTimes = []; // Jam operasional vendor (ex: 08:00, 09:00)
  List<String> _bookedTimes = [];    // Jam yang sudah dibooking orang lain
  
  bool _isLoading = true;
  String _courtName = "";
  double _courtPrice = 0.0; // Harga dari database

  @override
  void initState() {
    super.initState();
    _fetchCourtData();
  }

  // --- 1. AMBIL DATA DARI FIREBASE ---
  Future<void> _fetchCourtData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('venues')
          .doc(widget.courtId.toString())
          .get();

      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          // Ambil Nama
          _courtName = data['name'] ?? "Lapangan";
          
          // Ambil Harga (Handle int/double)
          _courtPrice = (data['price'] ?? 0).toDouble();

          // Ambil Jam Operasional yang diinput Vendor
          // Pastikan field di Firebase bernama 'availableTimes' (sesuai AddVenueScreen)
          _availableTimes = List<String>.from(data['availableTimes'] ?? []);
          
          // Urutkan jam dari pagi ke malam
          _availableTimes.sort(); 
        });

        // Cek slot yang sudah terisi jika tanggal sudah dipilih
        if (_selectedDate != null) {
          _updateBookedTimes();
        }
      }
    } catch (e) {
      print("Error fetching court data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- 2. CEK SLOT TERISI (LOGIKA BOOKING) ---
  // Fungsi ini mengecek koleksi 'bookings' untuk melihat apakah ada yang bentrok
  Future<void> _updateBookedTimes() async {
    if (_selectedDate == null) return;

    setState(() => _bookedTimes.clear());

    final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    try {
      // Query ke collection 'bookings' (Anda harus menyimpan data booking di sini saat payment sukses)
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('courtId', isEqualTo: widget.courtId)
          .where('date', isEqualTo: formattedDate)
          // Filter status agar booking yang batal tidak memblokir slot
          // .where('status', whereIn: ['paid', 'pending']) 
          .get();

      List<String> tempBooked = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Misal data booking menyimpan: time: "10:00", duration: 2
        String startTime = data['time'];
        int duration = data['duration'] ?? 1;

        // Blokir jam sesuai durasi
        // Contoh: Mulai 10:00, Durasi 2 jam -> Blokir 10:00 dan 11:00
        int startIndex = _availableTimes.indexOf(startTime);
        if (startIndex != -1) {
          for (int i = 0; i < duration; i++) {
            if (startIndex + i < _availableTimes.length) {
              tempBooked.add(_availableTimes[startIndex + i]);
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _bookedTimes = tempBooked;
        });
      }
    } catch (e) {
      print("Error checking bookings: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)), // Max booking 30 hari ke depan
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00B47A),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null; // Reset jam saat ganti tanggal
      });
      
      // Cek ketersediaan slot untuk tanggal baru
      _updateBookedTimes();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hitung Total Biaya
    final totalCost = _courtPrice * _selectedDuration;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Booking $_courtName",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00B47A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("📅 Pilih Tanggal"),
                  _buildDateSelector(context),
                  const SizedBox(height: 25),
                  
                  _buildSectionTitle("⏱️ Durasi (Jam)"),
                  _buildDurationSelector(),
                  const SizedBox(height: 25),
                  
                  _buildSectionTitle("⏰ Pilih Waktu Mulai"),
                  _buildTimeGrid(),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(totalCost),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey.shade800,
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedDate == null
                ? "Pilih Tanggal Booking"
                : DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate!),
            style: TextStyle(
              fontSize: 16,
              color: _selectedDate == null ? Colors.grey.shade600 : Colors.black87,
              fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Color(0xFF00B47A)),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Row(
      children: [
        _buildDurationButton("-", () {
          if (_selectedDuration > 1) {
            setState(() => _selectedDuration--);
          }
        }),
        Container(
          width: 80,
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            "$_selectedDuration Jam",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        _buildDurationButton("+", () {
          setState(() => _selectedDuration++);
        }),
      ],
    );
  }

  Widget _buildDurationButton(String text, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF00B47A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTimeGrid() {
    // Jika belum pilih tanggal, minta pilih tanggal dulu
    if (_selectedDate == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200)
        ),
        child: const Text(
          "Silakan pilih tanggal terlebih dahulu untuk melihat ketersediaan jam.",
          style: TextStyle(color: Colors.orange),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_availableTimes.isEmpty) {
      return const Center(child: Text("Tidak ada jam tersedia untuk lapangan ini."));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _availableTimes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2.2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final time = _availableTimes[index];
        
        // Logika Status Slot
        final isBooked = _bookedTimes.contains(time);
        final isSelected = time == _selectedTime;

        return InkWell(
          onTap: isBooked
              ? null // Tidak bisa diklik kalau sudah dibooking
              : () {
                  setState(() {
                    _selectedTime = time;
                  });
                },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isBooked
                  ? Colors.red.shade100 // Warna Merah (Full)
                  : isSelected
                      ? const Color(0xFF00B47A) // Warna Hijau (Dipilih)
                      : Colors.white, // Warna Putih (Available)
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isBooked
                    ? Colors.red.shade300
                    : isSelected
                        ? const Color(0xFF00B47A)
                        : Colors.grey.shade300,
              ),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: isBooked
                    ? Colors.red.shade700
                    : isSelected
                        ? Colors.white
                        : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(double totalCost) {
    // Tombol aktif hanya jika Tanggal & Jam sudah dipilih
    bool isButtonEnabled = _selectedDate != null && _selectedTime != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Biaya:",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                "Rp ${NumberFormat('#,##0', 'id_ID').format(totalCost)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B47A),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: isButtonEnabled
                ? () {
                    // Tampilkan Bottom Sheet Pembayaran
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return PaymentBottomSheet(
                          courtId: widget.courtId,
                          selectedDate: _selectedDate!,
                          selectedTime: _selectedTime!,
                          duration: _selectedDuration,
                          totalCost: totalCost,
                          courtName: _courtName,
                          basePrice: _courtPrice,
                        );
                      },
                    );
                  }
                : null, // Disable jika belum lengkap
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B47A),
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "LANJUT BOOKING",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}