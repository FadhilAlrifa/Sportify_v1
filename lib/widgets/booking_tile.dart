import 'package:flutter/material.dart';
import '../models/booking.dart';

class BookingTile extends StatelessWidget {
  final Booking booking;
  const BookingTile({Key? key, required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Booking ${booking.id.substring(0, 6)}'),
        subtitle: Text(booking.formattedTime),
        trailing: Text(booking.status.toString().split('.').last),
      ),
    );
  }
}
