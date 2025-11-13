import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/booking.dart';

class BookingProvider extends ChangeNotifier {
  final List<Booking> _bookings = [];

  List<Booking> get bookings => List.unmodifiable(_bookings);

  Future<Booking> createBooking(
      {required String courtId,
      required String userId,
      required DateTime start,
      required DateTime end,
      required double total}) async {
    final id = const Uuid().v4();
    final booking = Booking(
        id: id,
        courtId: courtId,
        userId: userId,
        startTime: start,
        endTime: end,
        totalPrice: total);
    _bookings.add(booking);
    notifyListeners();
    return booking;
  }

  void updateStatus(String id, BookingStatus status) {
    final b = _bookings.firstWhere((e) => e.id == id);
    b.status = status;
    notifyListeners();
  }
}
