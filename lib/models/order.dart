import 'package:flutter/material.dart';

class OrderHistory {
  final String id;
  final String courtName;
  final String imageUrl;
  final String date;
  final String time;
  final int price;
  final String status;

  OrderHistory({
    required this.id,
    required this.courtName,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.price,
    required this.status,
  });
}

// Dummy data
List<OrderHistory> dummyHistory = [
  OrderHistory(
    id: "1",
    courtName: "Arena Futsal",
    imageUrl: "https://i.imgur.com/GYQ8Q89.jpg",
    date: "12 Jan 2025",
    time: "14:00 - 15:00",
    price: 70000,
    status: "Completed",
  ),
  OrderHistory(
    id: "2",
    courtName: "Lapangan Voli",
    imageUrl: "https://i.imgur.com/yYqv0eG.jpg",
    date: "12 Jan 2025",
    time: "16:00 - 17:00",
    price: 60000,
    status: "Pending",
  ),
];
