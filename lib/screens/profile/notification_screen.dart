import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _notifBooking = true;
  bool _notifPromo = false;
  bool _notifApp = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pengaturan Notifikasi", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSwitch("Status Booking", "Dapatkan update status booking lapangan", _notifBooking, (val) {
            setState(() => _notifBooking = val);
          }),
          const Divider(),
          _buildSwitch("Promo & Diskon", "Notifikasi promo menarik untuk Anda", _notifPromo, (val) {
            setState(() => _notifPromo = val);
          }),
          const Divider(),
          _buildSwitch("Update Aplikasi", "Info fitur baru dan maintenance", _notifApp, (val) {
            setState(() => _notifApp = val);
          }),
        ],
      ),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      activeColor: const Color(0xFF00B380),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
    );
  }
}