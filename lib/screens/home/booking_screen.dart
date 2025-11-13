import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/payment_service.dart';

class BookingScreen extends StatefulWidget {
  final String? courtId;
  const BookingScreen({Key? key, this.courtId}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _start;
  DateTime? _end;
  bool _loading = false;

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final dt = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: now.add(const Duration(days: 60)));
    if (dt == null) return;
    final t = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
    if (t == null) return;
    setState(
        () => _start = DateTime(dt.year, dt.month, dt.day, t.hour, t.minute));
  }

  Future<void> _pickEnd() async {
    final now = DateTime.now();
    final dt = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: now.add(const Duration(days: 60)));
    if (dt == null) return;
    final t = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 10, minute: 0));
    if (t == null) return;
    setState(
        () => _end = DateTime(dt.year, dt.month, dt.day, t.hour, t.minute));
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
                title: Text('Mulai'),
                subtitle: Text(_start?.toString() ?? '-'),
                onTap: _pickStart),
            ListTile(
                title: Text('Selesai'),
                subtitle: Text(_end?.toString() ?? '-'),
                onTap: _pickEnd),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      if (!auth.isLoggedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Silakan login terlebih dahulu')));
                        return;
                      }
                      if (_start == null ||
                          _end == null ||
                          !_end!.isAfter(_start!)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Pilih waktu dengan benar')));
                        return;
                      }
                      setState(() => _loading = true);
                      final durationHours =
                          _end!.difference(_start!).inMinutes / 60.0;
                      final price = 100000.0 * durationHours; // contoh
                      final paymentOk = await PaymentService()
                          .pay(userId: auth.userId!, amount: price);
                      if (!paymentOk) {
                        setState(() => _loading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pembayaran gagal')));
                        return;
                      }
                      final booking = await bookingProvider.createBooking(
                          courtId: widget.courtId ?? '1',
                          userId: auth.userId!,
                          start: _start!,
                          end: _end!,
                          total: price);
                      setState(() => _loading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Booking berhasil')));
                      Navigator.popUntil(context, ModalRoute.withName('/home'));
                    },
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Bayar & Konfirmasi'),
            )
          ],
        ),
      ),
    );
  }
}
