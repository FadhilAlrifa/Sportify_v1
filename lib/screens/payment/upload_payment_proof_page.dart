import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadPaymentProofPage extends StatefulWidget {
  final String paymentMethod;
  final dynamic courtId;
  final DateTime date;
  final String time;
  final int duration;
  final double totalCost;

  const UploadPaymentProofPage({
    super.key,
    required this.paymentMethod,
    required this.courtId,
    required this.date,
    required this.time,
    required this.duration,
    required this.totalCost,
  });

  @override
  State<UploadPaymentProofPage> createState() => _UploadPaymentProofPageState();
}

class _UploadPaymentProofPageState extends State<UploadPaymentProofPage> {
  Uint8List? _imageBytes; // untuk preview di web & mobile
  XFile? _pickedFile; // untuk upload ke Supabase

  // Pick image (mobile & web)
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      _pickedFile = picked;

      // convert ke bytes untuk image preview
      final bytes = await picked.readAsBytes();

      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  // Upload ke supabase
  Future<void> uploadToSupabase() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih gambar terlebih dahulu")),
      );
      return;
    }

    final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

    try {
      await Supabase.instance.client.storage
          .from('transaction')
          .uploadBinary(fileName, _imageBytes!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload berhasil!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload gagal: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Bukti Pembayaran")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ======================
            //      IMAGE PREVIEW
            // ======================
            _imageBytes != null
                ? Image.memory(_imageBytes!, height: 240)
                : Container(
                    height: 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Text("Belum ada gambar")),
                  ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pilih Gambar"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: uploadToSupabase,
              child: const Text("Upload Sekarang"),
            ),
          ],
        ),
      ),
    );
  }
}
