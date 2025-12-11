import 'package:flutter/material.dart';
import 'package:sportify/screens/vendor/validation_screen.dart';

// --- IMPORTS SCREEN ---
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/court_detail_screen.dart';
import 'screens/home/booking_screen.dart';
import 'screens/vendor/vendor_venue_list_screen.dart'; // Tambahkan import ini
import 'screens/vendor/add_venue_screen.dart'; // Tambahkan import ini jika sudah ada

class Routes {
  // Definisi String Rute
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String courtDetail = '/courtDetail';
  static const String booking = '/booking';
  static const String addVenue = '/addVenue'; // <-- GANTI DENGAN CONST
  static const String vendorVenueList = '/vendorVenueList'; // Tambahkan ini jika belum ada
  static const String validation = '/validation';

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
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      // 4. DETAIL LAPANGAN
      case courtDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CourtDetailScreen(
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

      // 6. TAMBAH LAPANGAN (VENDOR)
      case addVenue:
        return MaterialPageRoute(
          builder: (_) => const AddVenueScreen(), // Buat file ini nanti
        );

      // 7. DAFTAR LAPANGAN VENDOR
      case vendorVenueList:
        return MaterialPageRoute(
          builder: (_) => const VendorVenueListScreen(),
        );

      // 8. VALIDATION SCREEN
      case validation: 
        return MaterialPageRoute(builder: (_) => const ValidationScreen());

      // 8. DEFAULT (Jika rute tidak ditemukan)
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
