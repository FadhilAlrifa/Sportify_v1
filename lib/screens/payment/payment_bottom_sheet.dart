import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'payment_summary_widget.dart';
import 'payment_method_item.dart';

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
      initialChildSize: 0.70,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(12),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: const [
                    PaymentMethodItem(label: "DANA", icon: Icons.wallet),
                    PaymentMethodItem(label: "OVO", icon: Icons.phone_android),
                    PaymentMethodItem(label: "GoPay", icon: Icons.payment),
                    PaymentMethodItem(
                        label: "Transfer Bank", icon: Icons.account_balance),
                  ],
                ),
              ),
              const SizedBox(height: 10),
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
                        fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
