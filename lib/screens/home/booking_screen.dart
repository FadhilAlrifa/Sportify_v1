import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  final List<Map<String, dynamic>> availableTimes = const [
    {"time": "08:00", "isBooked": false},
    {"time": "09:00", "isBooked": false},
    {"time": "10:00", "isBooked": true},
    {"time": "11:00", "isBooked": false},
    {"time": "12:00", "isBooked": false},
    {"time": "13:00", "isBooked": false},
    {"time": "14:00", "isBooked": true},
    {"time": "15:00", "isBooked": false},
    {"time": "16:00", "isBooked": false},
    {"time": "17:00", "isBooked": false},
  ];

  final double basePrice = 150000;

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
      });
    }
  }

  void _confirmBooking(BuildContext context) {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi Tanggal dan Waktu Booking."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final total = basePrice * _selectedDuration;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Booking"),
        content: Text(
            "Anda akan memesan lapangan ID: ${widget.courtId} pada tanggal ${DateFormat('dd MMM yyyy').format(_selectedDate!)} pukul ${_selectedTime} selama $_selectedDuration jam. Total biaya: Rp ${NumberFormat('#,##0', 'id_ID').format(total)}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Booking berhasil! (Simulasi)"),
                  backgroundColor: Color(0xFF00B47A),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B47A)),
            child: const Text("Pesan Sekarang",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCost = basePrice * _selectedDuration;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "Booking Lapangan: ${widget.courtId}",
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: availableTimes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2.5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final timeData = availableTimes[index];
        final time = timeData["time"] as String;
        final isBooked = timeData["isBooked"] as bool;
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
                ? () => _confirmBooking(context)
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
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}