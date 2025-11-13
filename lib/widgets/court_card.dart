import 'package:flutter/material.dart';
import '../models/court.dart';
import '../routes.dart';

class CourtCard extends StatelessWidget {
  final Court court;
  const CourtCard({Key? key, required this.court}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: court.imageUrl.isEmpty
            ? const Icon(Icons.sports_soccer)
            : Image.network(court.imageUrl),
        title: Text(court.name),
        subtitle: Text(court.location +
            ' • Rp ${court.pricePerHour.toStringAsFixed(0)}/jam'),
        onTap: () => Navigator.pushNamed(context, Routes.courtDetail,
            arguments: {'id': court.id}),
      ),
    );
  }
}
