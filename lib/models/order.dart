import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderHistory {
  final String id;
  final String courtId;
  final String courtName;
  final String date;
  final String time;
  final int duration;
  final double basePrice;
  final double totalCost;
  final String paymentMethod;
  final String paymentProofUrl;
  final String status;
  final String? userId;
  final String? userEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderHistory({
    required this.id,
    required this.courtId,
    required this.courtName,
    required this.date,
    required this.time,
    required this.duration,
    required this.basePrice,
    required this.totalCost,
    required this.paymentMethod,
    required this.paymentProofUrl,
    required this.status,
    this.userId,
    this.userEmail,
    this.createdAt,
    this.updatedAt,
  });

  // Factory method untuk membuat OrderHistory dari Firestore DocumentSnapshot
  factory OrderHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderHistory(
      id: doc.id,
      courtId: data['court_id']?.toString() ?? '',
      courtName: data['court_name']?.toString() ?? 'Lapangan',
      date: data['date']?.toString() ?? '',
      time: data['time']?.toString() ?? '',
      duration: (data['duration'] as int?) ?? 1,
      basePrice: (data['base_price'] as num?)?.toDouble() ?? 0.0,
      totalCost: (data['total_cost'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: data['payment_method']?.toString() ?? '',
      paymentProofUrl: data['payment_proof_url']?.toString() ?? '',
      status: data['status']?.toString() ?? 'pending',
      userId: data['user_id']?.toString(),
      userEmail: data['user_email']?.toString(),
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  // Helper untuk mendapatkan format tanggal yang lebih baik
  String get formattedDate {
    try {
      // Coba parse format yyyy-MM-dd
      final parts = date.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);

        final monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];

        return '$day ${monthNames[month - 1]} $year';
      }
      return date;
    } catch (e) {
      return date;
    }
  }

  // Helper untuk status dengan warna
  Color get statusColor {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('selesai') ||
        statusLower.contains('completed') ||
        statusLower.contains('confirmed')) {
      return Colors.green;
    } else if (statusLower.contains('pending') ||
        statusLower.contains('menunggu')) {
      return Colors.orange;
    } else if (statusLower.contains('cancel') ||
        statusLower.contains('dibatalkan')) {
      return Colors.red;
    } else if (statusLower.contains('belum dibayar')) {
      return Colors.red.shade700;
    }
    return Colors.grey;
  }

  // Helper untuk icon status
  IconData get statusIcon {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('selesai') || statusLower.contains('completed')) {
      return Icons.check_circle;
    } else if (statusLower.contains('pending')) {
      return Icons.access_time;
    } else if (statusLower.contains('cancel')) {
      return Icons.cancel;
    } else if (statusLower.contains('belum dibayar')) {
      return Icons.payment;
    }
    return Icons.info;
  }
}
