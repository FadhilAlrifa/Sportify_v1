import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <--- INI PERBAIKANNYA

class OrderHistory {
  final String id;
  final String courtName;
  final String imageUrl;
  final String date;
  final String time;
  final int price;
  final String status;

  const OrderHistory({
    required this.id,
    required this.courtName,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.price,
    required this.status,
  });
}

// Dummy data (Ditingkatkan untuk menguji filter waktu)
List<OrderHistory> dummyHistory = [
  // HARI INI
  OrderHistory(
    id: "1",
    courtName: "Arena Futsal A",
    imageUrl: "https://i.imgur.com/GYQ8Q89.jpg",
    date: DateFormat('d MMM yyyy').format(DateTime.now()), // Hari ini
    time: "14:00 - 15:00",
    price: 70000,
    status: "Selesai", 
  ),
  // MINGGU INI (misalnya 3 hari yang lalu)
  OrderHistory(
    id: "2",
    courtName: "Lapangan Voli B",
    imageUrl: "https://i.imgur.com/yYqv0eG.jpg",
    date: DateFormat('d MMM yyyy').format(DateTime.now().subtract(const Duration(days: 3))),
    time: "16:00 - 17:00",
    price: 60000,
    status: "Pending",
  ),
  // BULAN INI (misalnya 15 hari yang lalu)
  OrderHistory(
    id: "3",
    courtName: "Gedung Badminton C",
    imageUrl: "https://i.imgur.com/yYqv0eG.jpg",
    date: DateFormat('d MMM yyyy').format(DateTime.now().subtract(const Duration(days: 15))),
    time: "09:00 - 10:00",
    price: 90000,
    status: "Selesai",
  ),
  // BULAN LALU (tidak termasuk dalam filter 'month')
  OrderHistory(
    id: "4",
    courtName: "Kolam Renang D",
    imageUrl: "https://i.imgur.com/GYQ8Q89.jpg",
    date: DateFormat('d MMM yyyy').format(DateTime.now().subtract(const Duration(days: 40))),
    time: "11:00 - 12:00",
    price: 120000,
    status: "Pending",
  ),
];