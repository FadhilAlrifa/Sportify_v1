import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Import Routes
import 'routes.dart';

// Import Providers
import 'providers/auth_provider.dart';
import 'providers/court_provider.dart';
import 'providers/booking_provider.dart';


// Import Screens
import 'screens/auth/login_screen.dart';
// PENTING: Kita import HomeScreen dari folder home
import 'screens/home/home_screen.dart';
// import 'screens/history/history_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID', null);

  runApp(const SportifyApp());
}

class SportifyApp extends StatelessWidget {
  const SportifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Daftarkan semua Provider
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CourtProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'Sportify',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.grey[50],
          // Mengatur font default atau styling input agar konsisten
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
        ),

        // --- LOGIKA HALAMAN UTAMA (AUTO-LOGIN) ---
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            // Jika User sudah Login
            if (auth.isLoggedIn) {
              // Langsung masuk ke HomeScreen (yang sudah punya Nav Bar)
              return const HomeScreen();
            }
            // Jika belum Login
            return const LoginScreen();
          },
        ),

        // --- SISTEM NAVIGASI ---
        // Menggunakan generator dari routes.dart
        onGenerateRoute: Routes.generate,
      ),
    );
  }
}
