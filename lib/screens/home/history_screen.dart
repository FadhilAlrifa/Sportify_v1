import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/booking_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bp = Provider.of<BookingProvider>(context);
    return ListView.builder(
      itemCount: bp.bookings.length,
      itemBuilder: (ctx, i) => BookingTile(booking: bp.bookings[i]),
    );
  }
}
