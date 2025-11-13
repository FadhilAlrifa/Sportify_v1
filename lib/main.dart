import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/court_provider.dart';
import 'providers/booking_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
// Inisialisasi Firebase kalau dipakai
// await Firebase.initializeApp();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => CourtProvider()),
      ChangeNotifierProvider(create: (_) => BookingProvider()),
    ],
    child: const SportifyApp(),
  ));
}
