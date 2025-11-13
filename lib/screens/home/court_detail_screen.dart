import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/court_service.dart';
import '../../models/court.dart';
import '../../routes.dart';

class CourtDetailScreen extends StatefulWidget {
  final String? courtId;
  const CourtDetailScreen({Key? key, this.courtId}) : super(key: key);

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  Court? _court;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = CourtService();
    final c = await s.getCourtById(widget.courtId ?? '1');
    setState(() {
      _court = c;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_court == null)
      return Scaffold(body: Center(child: Text('Lapangan tidak ditemukan')));
    return Scaffold(
      appBar: AppBar(title: Text(_court!.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_court!.location),
            const SizedBox(height: 8),
            Text('Harga: Rp ${_court!.pricePerHour.toStringAsFixed(0)}/jam'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, Routes.booking,
                    arguments: {'id': _court!.id});
              },
              child: const Text('Pesan Sekarang'),
            )
          ],
        ),
      ),
    );
  }
}
