import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Bantuan & Support", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Pertanyaan Umum (FAQ)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 15),
          _buildFAQItem("Bagaimana cara booking?", "Pilih lapangan di home, pilih jam, dan lakukan pembayaran."),
          _buildFAQItem("Bagaimana cara refund?", "Refund dapat dilakukan maksimal 24 jam sebelum jadwal main."),
          
          const SizedBox(height: 30),
          const Text("Hubungi Kami", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 15),
          
          ListTile(
            leading: const Icon(Ionicons.logo_whatsapp, color: Colors.green),
            title: const Text("WhatsApp Admin"),
            onTap: () {}, // Tambahkan logika launchUrl ke WA
          ),
          ListTile(
            leading: const Icon(Ionicons.mail, color: Colors.blue),
            title: const Text("Email Support"),
            subtitle: const Text("support@sportify.com"),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: TextStyle(color: Colors.grey.shade600)),
        )
      ],
    );
  }
}