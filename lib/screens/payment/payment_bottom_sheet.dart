import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'payment_summary_widget.dart';

class PaymentBottomSheet extends StatelessWidget {
  final dynamic courtId;
  final DateTime selectedDate;
  final String selectedTime;
  final int duration;
  final double totalCost;

  const PaymentBottomSheet({
    super.key,
    required this.courtId,
    required this.selectedDate,
    required this.selectedTime,
    required this.duration,
    required this.totalCost,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.55,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Pembayaran",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                PaymentSummaryWidget(
                  courtId: courtId,
                  date: selectedDate,
                  time: selectedTime,
                  duration: duration,
                  totalCost: totalCost,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Metode Pembayaran",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                /// QRIS SECTION
                _buildQrisSection(context),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Pembayaran berhasil! (Simulasi)"),
                          backgroundColor: Color(0xFF00B47A),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B47A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Konfirmasi Pembayaran",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQrisSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // --- QRIS LOGO ---
          SizedBox(
            height: 40,
            child: Image.asset(
              "qris_logo.png", // Ubah sesuai folder asetmu
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 15),

          const Text(
            "Scan QR Code berikut untuk melakukan pembayaran",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),

          const SizedBox(height: 20),

          // --- QR CODE IMAGE ---
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Image.asset(
              "qris_sample.jpg", // QR Code kamu
              width: 180,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
