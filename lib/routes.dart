import 'package:flutter/material.dart';

// --- IMPORTS SCREEN ---
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart'; // <--- PENTING: Import MainScreen (Cangkang Navigasi)
import 'screens/home/court_detail_screen.dart';
import 'screens/home/booking_screen.dart'; 
// import 'screens/home/home_screen.dart'; // Tidak wajib di-import di sini jika pakai MainScreen

class Routes {
  // Definisi String Rute
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String courtDetail = '/courtDetail';
  static const String booking = '/booking';

  // Generator Rute
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      
      // 1. LOGIN
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      // 2. REGISTER
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      // 3. HOME (MAIN SCREEN)
      // PENTING: Arahkan ke MainScreen agar Bottom Navigation Bar tetap ada
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      // 4. DETAIL LAPANGAN
      case courtDetail:
        // Menangkap argumen (Map) yang dikirim saat navigasi
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CourtDetailScreen(
            // Mengambil ID dengan aman (safe null check)
            courtId: args?['id']?.toString(),
          ),
        );

      // 5. BOOKING
      case booking:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => BookingScreen(
            courtId: args?['id']?.toString(),
          ),
        );

      // 6. DEFAULT (Jika rute tidak ditemukan)
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Halaman tidak ditemukan: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
