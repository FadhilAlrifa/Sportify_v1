import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sportify/screens/payment/payment_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingScreen extends StatefulWidget {
  final dynamic courtId;

  const BookingScreen({super.key, required this.courtId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  String? _selectedTime;
  int _selectedDuration = 1;
  List<String> _availableTimes = [];
  List<String> _bookedTimes = [];
  bool _isLoading = true;
  double basePrice = 100000.0; // Harga dasar per jam
  String _courtName = "";
  double _courtPrice = 100000.0;

  @override
  void initState() {
    super.initState();
    _fetchCourtData();
  }

  // Fungsi untuk mengambil data jam tersedia dari Firebase
  Future<void> _fetchCourtData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('venues')
          .doc(widget.courtId.toString())
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // 1. Ambil nama lapangan
        _courtName = data['name'] ?? "Lapangan";

        // Ambil semua jam yang tersedia
        final List<dynamic> times = data['available_times'] ?? [];
        _availableTimes = times.map((time) => time.toString()).toList();

        // Ambil jam yang sudah dibooking untuk tanggal yang dipilih
        if (_selectedDate != null) {
          _updateBookedTimes(data);
        }

        print("Court data loaded: $_courtName, Price: $_courtPrice"); // DEBUG
      }
    } catch (e) {
      print("Error fetching availability: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk update jam yang sudah dibooking
  void _updateBookedTimes(Map<String, dynamic> data) {
    _bookedTimes.clear();

    final String formattedDate =
        DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final List<dynamic> bookedSlots = data['booked_slots'] ?? [];

    for (var slot in bookedSlots) {
      if (slot['date'] == formattedDate) {
        final List<dynamic> times = slot['times'] ?? [];
        _bookedTimes.addAll(times.map((time) => time.toString()));
        break;
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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
        _selectedTime = null;
        _bookedTimes.clear();
      });

      // Refresh data booking untuk tanggal yang dipilih
      await _fetchCourtData();
    }
  }


  @override
  Widget build(BuildContext context) {
    final totalCost = _courtPrice * _selectedDuration;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Booking ${_courtName.isNotEmpty ? _courtName : 'Lapangan'}",
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00B47A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
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
                : DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                    .format(_selectedDate!),
            style: TextStyle(
              fontSize: 16,
              color:
                  _selectedDate == null ? Colors.grey.shade600 : Colors.black87,
              fontWeight:
                  _selectedDate == null ? FontWeight.normal : FontWeight.w600,
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
            setState(() {
              _selectedDuration--;
            });
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
          setState(() {
            _selectedDuration++;
          });
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
          style: const TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTimeGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _availableTimes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2.5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final time = _availableTimes[index];
        final isBooked = _bookedTimes.contains(time);
        final isSelected = time == _selectedTime && !isBooked;

        return InkWell(
          onTap: isBooked
              ? null
              : () {
                  setState(() {
                    _selectedTime = time;
                  });
                },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isBooked
                  ? Colors.red.shade100
                  : isSelected
                      ? const Color(0xFF00B47A)
                      : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isBooked
                    ? Colors.red.shade400
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
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(double totalCost) {
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
            onPressed: (_selectedDate != null && _selectedTime != null)
                ? () {
                    final totalCost = basePrice * _selectedDuration;

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
                          basePrice: basePrice,
                        );
                      },
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B47A),
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