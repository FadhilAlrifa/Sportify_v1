import 'package:flutter/material.dart';
import 'payment_summary_widget.dart';
import 'payment_method_item.dart';

class PaymentBottomSheet extends StatefulWidget {
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
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  String selectedPayment = "QRIS"; // default

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // <-- FIX BACKGROUND TRANSPARAN
      padding: const EdgeInsets.all(20),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PaymentSummaryWidget(
            courtId: widget.courtId,
            date: widget.selectedDate,
            time: widget.selectedTime,
            duration: widget.duration,
            totalCost: widget.totalCost,
          ),

          const SizedBox(height: 20),

          const Text(
            "Pilih Metode Pembayaran",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          // --- PAYMENT METHODS ---
          PaymentMethodItem(
            label: "Gopay",
            icon: Icons.account_balance_wallet,
            selected: selectedPayment == "Gopay",
            onTap: () => setState(() => selectedPayment = "Gopay"),
          ),
          const SizedBox(height: 12),

          PaymentMethodItem(
            label: "OVO",
            icon: Icons.phone_android,
            selected: selectedPayment == "OVO",
            onTap: () => setState(() => selectedPayment = "OVO"),
          ),
          const SizedBox(height: 12),

          PaymentMethodItem(
            label: "QRIS",
            icon: Icons.qr_code,
            selected: selectedPayment == "QRIS",
            onTap: () => setState(() => selectedPayment = "QRIS"),
          ),

          const SizedBox(height: 20),

          // ===============================
          //     BAGIAN YANG DITAMPILKAN
          // ===============================

          if (selectedPayment == "Gopay" || selectedPayment == "OVO")
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    "Nomor Pembayaran: 083473857495",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

          if (selectedPayment == "QRIS")
            Center(
              child: Image.asset(
                "qris_sample.jpg",
                width: 180,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              print("Metode pembayaran: $selectedPayment");
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text("Bayar Sekarang"),
          ),
        ],
      ),
    );
  }
}
