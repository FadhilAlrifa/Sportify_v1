import 'package:intl/intl.dart';

enum BookingStatus { pending, confirmed, cancelled, completed }

class Booking {
  final String id;
  final String courtId;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  BookingStatus status;

  Booking(
      {required this.id,
      required this.courtId,
      required this.userId,
      required this.startTime,
      required this.endTime,
      required this.totalPrice,
      this.status = BookingStatus.pending});

  String get formattedTime =>
      '${DateFormat('yyyy-MM-dd HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}';
}
