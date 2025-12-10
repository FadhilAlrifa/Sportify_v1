import 'package:cloud_firestore/cloud_firestore.dart';

class OrderHistory {
  final String id;
  final String courtId;
  final String courtName;
  final String imageUrl;
  final DateTime date;
  final String time;
  final int duration;
  final int totalCost;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  OrderHistory({
    required this.id,
    required this.courtId,
    required this.courtName,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.duration,
    required this.totalCost,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  factory OrderHistory.fromFirestore(Map<String, dynamic> json, String id) {
    return OrderHistory(
      id: id,
      courtId: json['courtId']?.toString() ?? '',
      courtName: json['courtName']?.toString() ?? 'Unknown Court',
      imageUrl: json['imageUrl']?.toString() ?? 'assets/placeholder.jpg',

      date: (json['date'] as Timestamp).toDate(),

      time: json['time']?.toString() ?? '', // ← FIX PENTING!

      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse(json['duration'].toString()) ?? 0,

      totalCost: json['totalCost'] is int
          ? json['totalCost']
          : int.tryParse(json['totalCost'].toString()) ?? 0,

      paymentMethod: json['paymentMethod']?.toString() ?? '',

      status: json['status']?.toString() ?? 'Completed',

      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }


  int get price => totalCost;
}
