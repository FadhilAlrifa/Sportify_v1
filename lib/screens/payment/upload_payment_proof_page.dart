import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // ALIAS
import 'package:intl/intl.dart';

class UploadPaymentProofPage extends StatefulWidget {
  final String paymentMethod;
  final dynamic courtId;
  final String courtName;
  final double basePrice;
  final DateTime date;
  final String time;
  final int duration;
  final double totalCost;

  const UploadPaymentProofPage({
    super.key,
    required this.paymentMethod,
    required this.courtId,
    required this.courtName,
    required this.basePrice,
    required this.date,
    required this.time,
    required this.duration,
    required this.totalCost,
  });

  @override
  State<UploadPaymentProofPage> createState() => _UploadPaymentProofPageState();
}

class _UploadPaymentProofPageState extends State<UploadPaymentProofPage> {
  Uint8List? _imageBytes;
  XFile? _pickedFile;
  bool _isUploading = false;
  final firebase_auth.FirebaseAuth _auth =
      firebase_auth.FirebaseAuth.instance; // Pakai alias
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // VoidCallback? get pickImage => null;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    final bytes = await file.readAsBytes();

    setState(() {
      _pickedFile = file;
      _imageBytes = bytes;
    });
  }

  // Upload ke Supabase dan simpan ke Firebase
  Future<void> uploadAndSave() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih gambar terlebih dahulu")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Upload gambar ke Supabase
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final String filePath = 'payment_proofs/$fileName';

      await Supabase.instance.client.storage
          .from('transaction') // Pastikan bucket ini sudah dibuat di Supabase
          .uploadBinary(filePath, _imageBytes!);

      // 2. Dapatkan URL gambar dari Supabase
      final String imageUrl = Supabase.instance.client.storage
          .from('transaction')
          .getPublicUrl(filePath);

      // 3. Dapatkan user ID saat ini (PAKAI ALIAS)
      final firebase_auth.User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User belum login");
      }

      // 4. Simpan data booking ke Firebase
      final bookingData = {
        'court_id': widget.courtId,
        'court_name': widget.courtName,
        'user_id': user.uid,
        'user_email': user.email,
        'date': DateFormat('yyyy-MM-dd').format(widget.date),
        'time': widget.time,
        'duration': widget.duration,
        'base_price': widget.basePrice,
        'total_cost': widget.totalCost,
        'payment_method': widget.paymentMethod,
        'payment_proof_url': imageUrl,
        'status': 'pending', // Status awal
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      // 5. Simpan ke collection bookings
      await _firestore.collection('bookings').add(bookingData);

      // 6. Update booked_slots di venues
      await _updateVenueBookedSlots();

      // 7. Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Pembayaran berhasil diupload dan booking dikonfirmasi!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // 8. Navigasi kembali ke home atau halaman history
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      print("Error upload: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  // Fungsi untuk update booked_slots di venues
  Future<void> _updateVenueBookedSlots() async {
    try {
      final venueRef =
          _firestore.collection('venues').doc(widget.courtId.toString());
      final formattedDate = DateFormat('yyyy-MM-dd').format(widget.date);

      // Gunakan transaction untuk consistency
      await _firestore.runTransaction((transaction) async {
        final venueDoc = await transaction.get(venueRef);
        if (!venueDoc.exists) return;

        final data = venueDoc.data() as Map<String, dynamic>;
        List<dynamic> bookedSlots = data['booked_slots'] ?? [];

        // Cari apakah sudah ada booking untuk tanggal ini
        bool dateExists = false;
        for (int i = 0; i < bookedSlots.length; i++) {
          if (bookedSlots[i]['date'] == formattedDate) {
            // Tambahkan waktu baru ke array times
            List<dynamic> times = List.from(bookedSlots[i]['times'] ?? []);

            // Tambahkan semua slot waktu berdasarkan durasi
            final startTime = widget.time;
            final startHour = int.parse(startTime.split(':')[0]);

            for (int j = 0; j < widget.duration; j++) {
              final hour = startHour + j;
              final timeSlot = '${hour.toString().padLeft(2, '0')}:00';
              if (!times.contains(timeSlot)) {
                times.add(timeSlot);
              }
            }

            bookedSlots[i]['times'] = times;
            dateExists = true;
            break;
          }
        }

        // Jika tanggal belum ada, buat entry baru
        if (!dateExists) {
          List<String> times = [];
          final startHour = int.parse(widget.time.split(':')[0]);

          for (int i = 0; i < widget.duration; i++) {
            final hour = startHour + i;
            times.add('${hour.toString().padLeft(2, '0')}:00');
          }

          bookedSlots.add({
            'date': formattedDate,
            'times': times,
          });
        }

        // Update ke Firebase
        transaction.update(venueRef, {
          'booked_slots': bookedSlots,
          'updated_at': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print("Error updating venue booked slots: $e");
      // Tidak perlu throw, biarkan booking tetap tersimpan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Bukti Pembayaran"),
        backgroundColor: const Color(0xFF00B47A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informasi Booking
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Detail Booking:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text("Lapangan: ${widget.courtName}"),
                  Text(
                      "Tanggal: ${DateFormat('dd MMM yyyy').format(widget.date)}"),
                  Text("Waktu: ${widget.time}"),
                  Text("Durasi: ${widget.duration} jam"),
                  Text(
                      "Harga/jam: Rp ${NumberFormat('#,##0', 'id_ID').format(widget.basePrice)}"),
                  Text("Metode: ${widget.paymentMethod}"),
                  const SizedBox(height: 5),
                  Divider(color: Colors.grey.shade400),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Rp ${NumberFormat('#,##0', 'id_ID').format(widget.totalCost)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF00B47A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Preview Gambar
            const Text(
              "Bukti Pembayaran:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            _imageBytes != null
                ? Container(
                    width: double.infinity,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                    ),
                  )
                : Container(
                    height: 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("Belum ada gambar"),
                        SizedBox(height: 5),
                        Text(
                          "Format: JPG, PNG",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

            const SizedBox(height: 20),

            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Pilih Gambar"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : uploadAndSave,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(
                        _isUploading ? "Mengupload..." : "Upload & Simpan"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isUploading ? Colors.grey : const Color(0xFF00B47A),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Informasi tambahan
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Pastikan gambar bukti pembayaran jelas dan terbaca. Booking akan diproses setelah pembayaran dikonfirmasi.",
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
